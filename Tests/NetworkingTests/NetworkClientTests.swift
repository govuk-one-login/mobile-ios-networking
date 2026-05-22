import MockNetworking
@testable import Networking
import XCTest

final class NetworkClientTests: XCTestCase {
    private var configuration: URLSessionConfiguration!
    private var sut: NetworkClient!

    private var authorizationProvider: MockAuthorizationProvider!
    private var clientAttestationProvider: MockClientAttestationProvider!
    private var dPoPProvider: MockDPoPProvider!

    override func setUp() {
        super.setUp()
        
        configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]

        authorizationProvider = MockAuthorizationProvider()
        clientAttestationProvider = MockClientAttestationProvider()
        dPoPProvider = MockDPoPProvider()

        sut = .init(configuration: configuration)
        sut.authorizationProvider = authorizationProvider
        sut.clientAttestationProvider = clientAttestationProvider
        sut.dPoPProvider = dPoPProvider
    }
    
    override func tearDown() {
        sut = nil
        clientAttestationProvider = nil
        authorizationProvider = nil
        dPoPProvider = nil
        MockURLProtocol.clear()
        
        super.tearDown()
    }
}

extension NetworkClientTests {
    func test_tlsVersion() throws {
        XCTAssertEqual(configuration.tlsMinimumSupportedProtocolVersion, .TLSv12)
    }
    
    func test_initialisation_UsesProtocolCachePolicy() throws {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        
        _ = NetworkClient(configuration: configuration)
        
        XCTAssertEqual(configuration.requestCachePolicy, .useProtocolCachePolicy)
    }
    
    func test_convenienceInit_assertConfiguration() async throws {
        let sut = NetworkClient()
        let config = sut.debugSession.configuration
        
        XCTAssertEqual(config.requestCachePolicy, .useProtocolCachePolicy)
        XCTAssertNotNil(config.urlCache)
        XCTAssertNotNil(config.httpCookieStorage)
    }
    
    func test_makeRequest_returnsData() async throws {
        let originalDate = Date()
        let firstData = Data("{ testResult \(originalDate)}".utf8)
        
        MockURLProtocol.handler = {
            (firstData, HTTPURLResponse(statusCode: 200))
        }
        
        let firstResponse = try await sut.request(.example).execute()
        XCTAssertEqual(firstResponse, firstData)
        
        let secondData = Data("{ testResult \(Date())}".utf8)
        
        MockURLProtocol.handler = {
            (secondData, HTTPURLResponse(statusCode: 200))
        }
        
        let secondResponse = try await sut.request(.example).execute()
        XCTAssertEqual(secondResponse, secondData)
    }
    
    func test_makeRequest_returnsServerError() async throws {
        MockURLProtocol.handler = {
            (Data(), HTTPURLResponse(statusCode: 404))
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
        MockURLProtocol.handler = {
            (data, HTTPURLResponse(statusCode: 200))
        }
        // WHEN I make an authorized request
        let returnedData = try await sut.request(.example).withAuthentication(scope: "testScope").execute()
        XCTAssertEqual(returnedData, data)
        // THEN the correct scope is requested
        XCTAssertEqual(authorizationProvider.fetchedTokenScope, "testScope")
        // AND the access token is attached
        let request = try XCTUnwrap(MockURLProtocol.requests.first)
        let bearerToken = request.value(forHTTPHeaderField: "Authorization")
        XCTAssertEqual(bearerToken, "Bearer testBearerToken")
        let userAgent = request.allHTTPHeaderFields?["User-Agent"]
        XCTAssertEqual(userAgent, UserAgent().description)
    }
    
    func test_makeAttestationRequest() async throws {
        // GIVEN I can connect to the backend server
        let data = Data("{ testResult }".utf8)
        MockURLProtocol.handler = {
            (data, HTTPURLResponse(statusCode: 200))
        }
        // WHEN I make an attestation request
        let returnedData = try await sut.request(.example).withClientAttestation().execute()
        XCTAssertEqual(returnedData, data)
        // THEN the attestation headers are attached
        let request = try XCTUnwrap(MockURLProtocol.requests.first)
        let clientHeader = request.value(forHTTPHeaderField: "Test-Client-Attestation")
        XCTAssertEqual(clientHeader, "12345")
        let popHeader = request.value(forHTTPHeaderField: "Test-Client-Attestation-PoP")
        XCTAssertEqual(popHeader, "12345")
        
        let userAgent = request.allHTTPHeaderFields?["User-Agent"]
        XCTAssertEqual(userAgent, UserAgent().description)
    }

    func test_makeDPoPRequest() async throws {
        // GIVEN I can connect to the backend server
        let data = Data("{ testResult }".utf8)
        MockURLProtocol.handler = {
            (data, HTTPURLResponse(statusCode: 200))
        }
        // WHEN I make a dPoP request
        let returnedData = try await sut.request(.example).withDPoP().execute()
        XCTAssertEqual(returnedData, data)
        // THEN the dPoP headers are attached
        let request = try XCTUnwrap(MockURLProtocol.requests.first)
        let dPoPHeader = request.value(forHTTPHeaderField: "Test-DPoP")
        XCTAssertEqual(dPoPHeader, "12345")
        
        let userAgent = request.allHTTPHeaderFields?["User-Agent"]
        XCTAssertEqual(userAgent, UserAgent().description)
    }
    
    func test_makeAuthAndAttestationRequest() async throws {
        // GIVEN I can connect to the backend server
        let data = Data("{ testResult }".utf8)
        MockURLProtocol.handler = {
            (data, HTTPURLResponse(statusCode: 200))
        }
        // WHEN I make a request with multiple headers
        let returnedData = try await sut.request(.example).withAuthentication(scope: "testScope").withClientAttestation().withDPoP().execute()
        XCTAssertEqual(returnedData, data)
        // THEN all the headers are attached
        let request = try XCTUnwrap(MockURLProtocol.requests.first)
        let dPoPHeader = request.value(forHTTPHeaderField: "Test-DPoP")
        XCTAssertEqual(dPoPHeader, "12345")
        let clientHeader = request.value(forHTTPHeaderField: "Test-Client-Attestation")
        XCTAssertEqual(clientHeader, "12345")
        let popHeader = request.value(forHTTPHeaderField: "Test-Client-Attestation-PoP")
        XCTAssertEqual(popHeader, "12345")
        let bearerToken = request.value(forHTTPHeaderField: "Authorization")
        XCTAssertEqual(bearerToken, "Bearer testBearerToken")
        
        let userAgent = request.allHTTPHeaderFields?["User-Agent"]
        XCTAssertEqual(userAgent, UserAgent().description)
    }
}

// TODO: DCMAW-20369 Remove old tests when those methods are removed
extension NetworkClientTests {
    func test_makeRequest_returnsData_old() async throws {
        let originalDate = Date()
        let firstData = Data("{ testResult \(originalDate)}".utf8)
        
        MockURLProtocol.handler = {
            (firstData, HTTPURLResponse(statusCode: 200))
        }
        
        let firstResponse = try await sut.makeRequest(.example)
        XCTAssertEqual(firstResponse, firstData)
        
        let secondData = Data("{ testResult \(Date())}".utf8)
        
        MockURLProtocol.handler = {
            (secondData, HTTPURLResponse(statusCode: 200))
        }
        
        let secondResponse = try await sut.makeRequest(.example)
        XCTAssertEqual(secondResponse, secondData)
    }
    
    func test_makeRequest_returnsServerError_old() async throws {
        MockURLProtocol.handler = {
            (Data(), HTTPURLResponse(statusCode: 404))
        }
        
        do {
            _ = try await sut.makeRequest(.example)
        } catch {
            XCTAssert(error is ServerError)
        }
    }
    
    func test_makeAuthorizedRequest_attachesAuthorizationToken_old() async throws {
        // GIVEN I can connect to the backend server
        let data = Data("{ testResult }".utf8)
        MockURLProtocol.handler = {
            (data, HTTPURLResponse(statusCode: 200))
        }
        // WHEN I make an authorized request
        let returnedData = try await sut
            .makeAuthorizedRequest(scope: "testScope", request: .example)
        XCTAssertEqual(returnedData, data)
        // THEN the correct scope is requested
        XCTAssertEqual(authorizationProvider.fetchedTokenScope, "testScope")
        // AND the access token is attached
        let request = try XCTUnwrap(MockURLProtocol.requests.first)
        let bearerToken = request.value(forHTTPHeaderField: "Authorization")
        XCTAssertEqual(bearerToken, "Bearer testBearerToken")
        let userAgent = request.allHTTPHeaderFields?["User-Agent"]
        XCTAssertEqual(userAgent, UserAgent().description)
    }
}
