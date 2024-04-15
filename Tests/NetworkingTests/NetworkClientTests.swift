import MockNetworking
@testable import Networking
import XCTest

final class NetworkClientTests: XCTestCase {
    private var configuration: URLSessionConfiguration!
    private var sut: NetworkClient!
    
    private var exchangeUrlRequest: URLRequest!
    private var urlRequest: URLRequest!
    
    override func setUp() {
        super.setUp()
        
        configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        
        exchangeUrlRequest = URLRequest(url: URL(string: "https://www.test.com")!)
        urlRequest = URLRequest(url: URL(string: "https://www.test.com")!)
        
        sut = .init(configuration: configuration, authenticationProvider: MockAuthenticationProvider())
    }
    
    override func tearDown() {
        exchangeUrlRequest = nil
        urlRequest = nil
        
        sut = nil
        super.tearDown()
    }
}

extension NetworkClientTests {
    func test_tlsVersion() throws {
        XCTAssertEqual(configuration.tlsMinimumSupportedProtocolVersion, .TLSv12)
    }
    
    func test_makeRequest_returnsData() async throws {
        let data = try XCTUnwrap("{ testResult }".data(using: .utf8))
        
        MockURLProtocol.handler = {
            (data, HTTPURLResponse(statusCode: 200))
        }
        
        let returnedData = try await sut.makeRequest(urlRequest)
        XCTAssertEqual(returnedData, data)
    }
    
    func test_makeRequest_returnsServerError() async throws {
        MockURLProtocol.handler = {
            (Data(), HTTPURLResponse(statusCode: 404))
        }
        
        do {
            _ = try await sut.makeRequest(urlRequest)
        } catch {
            XCTAssert(error is ServerError)
        }
    }
    
    func test_makeAuthorizedRequest_returnsData() async throws {
        let exchangeData = try XCTUnwrap("""
            {
                "access_token": "testAccessToken",
                "token_type": "testTokenType",
                "expires_in": 123456789
            }
        """.data(using: .utf8))
        let data = try XCTUnwrap("{ testResult }".data(using: .utf8))
        
        var requestsMade = 0
        MockURLProtocol.handler = {
            defer {
                requestsMade += 1
            }
            switch requestsMade {
            case 0:
                return (exchangeData, HTTPURLResponse(statusCode: 200))
            default:
                return (data, HTTPURLResponse(statusCode: 200))
            }
        }
        
        let returnedData = try await sut.makeAuthorizedRequest(exchangeRequest: exchangeUrlRequest,
                                                               scope: "testScope",
                                                               request: urlRequest)
        XCTAssertEqual(returnedData, data)
        
        let firstRequest = try XCTUnwrap(MockURLProtocol.requests.first)
        let contentType = firstRequest.value(forHTTPHeaderField: "Content-Type")
        let httpMethod = firstRequest.httpMethod
        XCTAssertEqual(contentType, "application/x-www-form-urlencoded")
        XCTAssertEqual(httpMethod, "POST")
        let bodyData = try XCTUnwrap(firstRequest.httpBodyData())
        let body = try XCTUnwrap(String(data: bodyData, encoding: .utf8)?.split(separator: "&"))
        XCTAssertEqual(body[0], "grant-type=urn:ietf:params:oauth:grant-type:token-exchange")
        XCTAssertEqual(body[1], "scope=testScope")
        XCTAssertEqual(body[2], "subject-token=testBearerToken")
        XCTAssertEqual(body[3], "subject-token-type=urn:ietf:params:oauth:token-type:access_token")
        
        let secondRequest = try XCTUnwrap(MockURLProtocol.requests.last)
        let bearerToken = secondRequest.value(forHTTPHeaderField: "Authorization")
        XCTAssertEqual(bearerToken, "Bearer testAccessToken")
    }
    
    func test_makeAuthorizedRequest_firstCall_returnsServerError() async throws {
        MockURLProtocol.handler = {
            (Data(), HTTPURLResponse(statusCode: 404))
        }
        
        do {
            _ = try await sut.makeAuthorizedRequest(exchangeRequest: exchangeUrlRequest,
                                                    scope: "testScope",
                                                    request: urlRequest)
        } catch {
            XCTAssert(error is ServerError)
        }
    }
    
    func test_makeAuthorizedRequest_secondCall_returnsServerError() async throws {
        let exchangeData = try XCTUnwrap("""
            {
                "access_token": "testAccessToken",
                "token_type": "testTokenType",
                "expires_in": 123456789
            }
        """.data(using: .utf8))
        
        var requestsMade = 0
        MockURLProtocol.handler = {
            defer {
                requestsMade += 1
            }
            switch requestsMade {
            case 0:
                return (exchangeData, HTTPURLResponse(statusCode: 200))
            default:
                return (Data(), HTTPURLResponse(statusCode: 404))
            }
        }
        
        do {
            _ = try await sut.makeAuthorizedRequest(exchangeRequest: exchangeUrlRequest,
                                                    scope: "testScope",
                                                    request: urlRequest)
        } catch {
            XCTAssert(error is ServerError)
        }
    }
}
