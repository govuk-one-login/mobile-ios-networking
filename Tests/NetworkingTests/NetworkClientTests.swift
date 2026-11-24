import MockNetworking
@testable import Networking
import XCTest

final class NetworkClientTests: XCTestCase {
    private var configuration: URLSessionConfiguration!
    private var sut: NetworkClient!

    private var authorizationProvider: MockAuthorizationProvider!
    private var clientAttestationProvider: MockClientAttestationProvider!
    private var dPoPProvider: MockDPoPProvider!

    override func setUp() async throws {
        try await super.setUp()
        
        let testConfiguration = URLSessionConfiguration.default
        configuration = testConfiguration
        configuration.protocolClasses = [MockURLProtocol.self]

        authorizationProvider = MockAuthorizationProvider()
        clientAttestationProvider = MockClientAttestationProvider()
        dPoPProvider = MockDPoPProvider()

        sut = await MainActor.run { .init(configuration: testConfiguration) }
        await sut.set(authorizationProvider: authorizationProvider)
        await sut.set(clientAttestationProvider: clientAttestationProvider)
        await sut.set(dPoPProvider: dPoPProvider)
    }
    
    override func tearDown() {
        sut = nil
        clientAttestationProvider = nil
        authorizationProvider = nil
        dPoPProvider = nil
        Task { await MainActor.run { MockURLProtocol.clear() } }
        
        super.tearDown()
    }
}

extension NetworkClientTests {
    func test_tlsVersion() throws {
        XCTAssertEqual(configuration.tlsMinimumSupportedProtocolVersion, .TLSv12)
    }
    
    func test_initialisation_UsesProtocolCachePolicy() async throws {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        
        _ =  await MainActor.run { NetworkClient(configuration: configuration) }
        
        XCTAssertEqual(configuration.requestCachePolicy, .useProtocolCachePolicy)
    }
    
    func test_convenienceInit_assertConfiguration() async throws {
        let sut = await MainActor.run { NetworkClient() }
        let config = await sut.debugSession.configuration
        
        XCTAssertEqual(config.requestCachePolicy, .useProtocolCachePolicy)
        XCTAssertNotNil(config.urlCache)
        XCTAssertNotNil(config.httpCookieStorage)
    }
    
    func test_makeRequest_returnsData() async throws {
        let originalDate = Date()
        let firstData = Data("{ testResult \(originalDate)}".utf8)
        
        await MainActor.run {
            MockURLProtocol.handler = { (firstData, HTTPURLResponse(statusCode: 200)) }
        }
        
        let firstResponse = try await sut.request(.example).execute()
        XCTAssertEqual(firstResponse, firstData)
        
        let secondData = Data("{ testResult \(Date())}".utf8)
        
        await MainActor.run {
            MockURLProtocol.handler = { (secondData, HTTPURLResponse(statusCode: 200)) }
        }
        
        let secondResponse = try await sut.request(.example).execute()
        XCTAssertEqual(secondResponse, secondData)
    }
    
    func test_makeRequest_returnsServerError() async throws {
        await MainActor.run {
            MockURLProtocol.handler = {(Data(), HTTPURLResponse(statusCode: 404))}
        }
        
        do {
            _ = try await sut.request(.example).execute()
        } catch {
            XCTAssert(error is ServerError)
            XCTAssertEqual((error as? ServerError)?.errorCode, 404)
        }
    }
    
    func test_makeAuthorizedRequest_attachesAuthorizationToken() async throws {
        // GIVEN I can connect to the backend server
        let data = Data("{ testResult }".utf8)
        await MainActor.run {
            MockURLProtocol.handler = { (data, HTTPURLResponse(statusCode: 200)) }
        }
        // WHEN I make an authorized request
        var exampleRequest = sut.request(.example)
        let returnedData = try await exampleRequest.withAuthentication(scope: "testScope").execute()
        XCTAssertEqual(returnedData, data)
        // THEN the correct scope is requested
        let fetchedTokenScope = await authorizationProvider.fetchedTokenScope
        XCTAssertEqual(fetchedTokenScope, "testScope")
        // AND the access token is attached
        let recordedRequests = await MainActor.run { MockURLProtocol.requests }
        let request = try XCTUnwrap(recordedRequests.first)
        let bearerToken = request.value(forHTTPHeaderField: "Authorization")
        XCTAssertEqual(bearerToken, "Bearer testBearerToken")
        let userAgent = request.allHTTPHeaderFields?["User-Agent"]
        let expectedUserAgent = await MainActor.run { UserAgent(device: UIDevice.current).description }
        XCTAssertEqual(userAgent, expectedUserAgent)
    }
    
    func test_makeAttestationRequest() async throws {
        // GIVEN I can connect to the backend server
        let data = Data("{ testResult }".utf8)
        await MainActor.run {
            MockURLProtocol.handler = {(data, HTTPURLResponse(statusCode: 200)) }
        }
        // WHEN I make an attestation request
        var exampleRequest = sut.request(.example)
        let returnedData = try await exampleRequest.withClientAttestation().execute()
        XCTAssertEqual(returnedData, data)
        // THEN the attestation headers are attached
        let receivedRequests = await MainActor.run { MockURLProtocol.requests }
        let request = try XCTUnwrap(receivedRequests.first)
        let clientHeader = request.value(forHTTPHeaderField: "Test-Client-Attestation")
        XCTAssertEqual(clientHeader, "12345")
        let popHeader = request.value(forHTTPHeaderField: "Test-Client-Attestation-PoP")
        XCTAssertEqual(popHeader, "12345")
        
        let userAgent = request.allHTTPHeaderFields?["User-Agent"]
        let expectedUserAgent = await MainActor.run { UserAgent(device: UIDevice.current).description }
        XCTAssertEqual(userAgent, expectedUserAgent)
    }

    func test_makeDPoPRequest() async throws {
        // GIVEN I can connect to the backend server
        let data = Data("{ testResult }".utf8)
        await MainActor.run {
            MockURLProtocol.handler = { (data, HTTPURLResponse(statusCode: 200)) }
        }
        // WHEN I make a dPoP request
        var exampleRequest = sut.request(.example)
        let returnedData = try await exampleRequest.withDPoP().execute()
        XCTAssertEqual(returnedData, data)
        // THEN the dPoP headers are attached
        let receivedRequests = await MainActor.run { MockURLProtocol.requests }
        let request = try XCTUnwrap(receivedRequests.first)
        let dPoPHeader = request.value(forHTTPHeaderField: "Test-DPoP")
        XCTAssertEqual(dPoPHeader, "12345")
        
        let userAgent = request.allHTTPHeaderFields?["User-Agent"]
        let expectedUserAgent = await MainActor.run { UserAgent(device: UIDevice.current).description }
        XCTAssertEqual(userAgent, expectedUserAgent)
    }
    
    func test_makeAuthAndAttestationRequest() async throws {
        // GIVEN I can connect to the backend server
        let data = Data("{ testResult }".utf8)
        await MainActor.run {
            MockURLProtocol.handler = { (data, HTTPURLResponse(statusCode: 200)) }
        }
        // WHEN I make a request with multiple headers
        var exampleRequest = sut.request(.example)
        exampleRequest = exampleRequest.withAuthentication(scope: "testScope")
        exampleRequest = exampleRequest.withClientAttestation()
        exampleRequest = exampleRequest.withDPoP()
        let returnedData = try await exampleRequest.execute()
        XCTAssertEqual(returnedData, data)
        // THEN all the headers are attached
        let receivedRequests = await MainActor.run { MockURLProtocol.requests }
        let request = try XCTUnwrap(receivedRequests.first)
        let dPoPHeader = request.value(forHTTPHeaderField: "Test-DPoP")
        XCTAssertEqual(dPoPHeader, "12345")
        let clientHeader = request.value(forHTTPHeaderField: "Test-Client-Attestation")
        XCTAssertEqual(clientHeader, "12345")
        let popHeader = request.value(forHTTPHeaderField: "Test-Client-Attestation-PoP")
        XCTAssertEqual(popHeader, "12345")
        let bearerToken = request.value(forHTTPHeaderField: "Authorization")
        XCTAssertEqual(bearerToken, "Bearer testBearerToken")
        
        let userAgent = request.allHTTPHeaderFields?["User-Agent"]
        let expectedUserAgent = await MainActor.run { UserAgent(device: UIDevice.current).description }
        XCTAssertEqual(userAgent, expectedUserAgent)
    }
}
