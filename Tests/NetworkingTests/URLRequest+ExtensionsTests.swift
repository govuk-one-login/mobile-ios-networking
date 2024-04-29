@testable import Networking
import XCTest

final class URLRequestTests: XCTestCase {
    var sut: URLRequest!
    
    override func setUp() {
        super.setUp()
        sut = URLRequest(url: URL(string: "https://www.google.com")!)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
}

extension URLRequestTests {
    func test_tokenExchange() throws {
        let tokenRequest = sut.tokenExchange(subjectToken: "tesSubjectToken", scope: "testScope")
        let contentTypeHeader = tokenRequest.value(forHTTPHeaderField: "Content-Type")
        let httpMethod = tokenRequest.httpMethod
        let body = try XCTUnwrap(String(data: try XCTUnwrap(tokenRequest.httpBody), encoding: .utf8)?.split(separator: "&"))
        XCTAssertEqual(tokenRequest.url, URL(string: "https://www.google.com"))
        XCTAssertEqual(contentTypeHeader, "application/x-www-form-urlencoded")
        XCTAssertEqual(httpMethod, "POST")
        XCTAssertEqual(body[0], "grant_type=urn:ietf:params:oauth:grant-type:token-exchange")
        XCTAssertEqual(body[1], "scope=testScope")
        XCTAssertEqual(body[2], "subject_token=tesSubjectToken")
        XCTAssertEqual(body[3], "subject_token_type=urn:ietf:params:oauth:token-type:access_token")
    }
    
    func test_authorized() throws {
        let authorizedRequest = sut.authorized(with: "testBearerToken")
        let authorizationHeader = authorizedRequest.value(forHTTPHeaderField: "Authorization")
        XCTAssertEqual(authorizationHeader, "Bearer testBearerToken")
    }
}
