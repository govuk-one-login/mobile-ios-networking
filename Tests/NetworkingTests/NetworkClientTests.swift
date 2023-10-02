import MockNetworking
@testable import Networking
import XCTest

final class NetworkClientTests: XCTestCase {
    private var configuration: URLSessionConfiguration!
    private var sut: NetworkClient!
    
    override func setUp() {
        super.setUp()
        
        configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        
        sut = .init(configuration: configuration)
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
        let url = try XCTUnwrap(URL(string: "https://www.google.com"))
        let data = try XCTUnwrap("{ }".data(using: . utf8))
        
        MockURLProtocol.handler = {
            (data, HTTPURLResponse(statusCode: 200))
        }
        
        let returnedData = try await sut.makeRequest(URLRequest(url: url))
        XCTAssertEqual(returnedData, data)
    }
    
    func test_makeRequest_returnsServerError() async throws {
        let url = try XCTUnwrap(URL(string: "https://www.google.com"))
        let data = try XCTUnwrap("{ }".data(using: . utf8))
        
        MockURLProtocol.handler = {
            (data, HTTPURLResponse(statusCode: 404))
        }
        
        do {
            _ = try await sut.makeRequest(URLRequest(url: url))
        } catch {
            XCTAssert(error is ServerError)
        }
    }
    
    func test_bearerToken_isInRequest() async throws {
        sut = nil
        sut = .init(configuration: configuration, authenticationProvider: MockAuthenticationProvider())
        
        let url = try XCTUnwrap(URL(string: "https://www.google.com"))
        let data = try XCTUnwrap("{ }".data(using: . utf8))
        
        MockURLProtocol.handler = {
            (data, HTTPURLResponse(statusCode: 404))
        }
        
        do {
            _ = try await sut.makeRequest(URLRequest(url: url))
        } catch {
            XCTAssert(error is ServerError)
        }
        
        guard let request = MockURLProtocol.requests.first else {
            XCTFail("request is nil")
            return
        }
        
        let bearerToken = request.value(forHTTPHeaderField: "Authorization")
        // swiftlint:disable line_length
        let tokenToCheck = """
      Bearer zh2JZEiVWK9AHJNQN3TiK7MFjbuECjyA-I9uL9oFHmNZv0v4HnJrs64ZiNjp9nOSJjAM7gBIWJXlnzxG07/wzSE?neXnLinU6YYAZ!Q2CRwxkeqWT=hBapLWnbP1g/5j2MXlnY7gw2T=?i6nBI86=MJ1NR!fxqlwg4iI73x9HTL15i6urRrICHEps2BEy0c0uAet6USg6dpy0fFnf6Cf!ZozO37TOJB=T7!FooE8HDlM8WXggsO6cDQdDzRS43gL
      """
        // swiftlint:enable line_length
        
        XCTAssertEqual(bearerToken, tokenToCheck)
    }
}
