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
}
