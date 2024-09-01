import MockNetworking
@testable import Networking
import XCTest

final class NetworkClientTests: XCTestCase {
    private var configuration: URLSessionConfiguration!
    private var sut: NetworkClient!

    private var authorizationProvider: MockAuthorizationProvider!

    override func setUp() {
        super.setUp()
        
        configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]

        authorizationProvider = MockAuthorizationProvider()

        sut = .init(configuration: configuration)
        sut.authorizationProvider = authorizationProvider
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
}

extension NetworkClientTests {
    func test_tlsVersion() throws {
        XCTAssertEqual(configuration.tlsMinimumSupportedProtocolVersion, .TLSv12)
    }
    
    func test_makeRequest_returnsData() async throws {
        let data = Data("{ testResult }".utf8)
        
        MockURLProtocol.handler = {
            (data, HTTPURLResponse(statusCode: 200))
        }

        let returnedData = try await sut.makeRequest(.example)
        XCTAssertEqual(returnedData, data)
    }
    
    func test_makeRequest_returnsServerError() async throws {
        MockURLProtocol.handler = {
            (Data(), HTTPURLResponse(statusCode: 404))
        }
        
        do {
            _ = try await sut.makeRequest(.example)
        } catch {
            XCTAssert(error is ServerError)
        }
    }
    
    func test_makeAuthorizedRequest_attachesAuthorizationToken() async throws {
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
        XCTAssertEqual(authorizationProvider.didFetchToken, "testScope")
        // AND the access token is attached
        let request = try XCTUnwrap(MockURLProtocol.requests.first)
        let bearerToken = request.value(forHTTPHeaderField: "Authorization")
        XCTAssertEqual(bearerToken, "Bearer testBearerToken")
    }
}

