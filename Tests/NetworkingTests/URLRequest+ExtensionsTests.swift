@testable import Networking
import XCTest

final class URLRequestTests: XCTestCase {
    func test_authorized() throws {
        let url = try XCTUnwrap(URL(string: "https://www.google.com"))
        let authorizedRequest = URLRequest(url: url).authorized(with: "testBearerToken")
        let authorizationHeader = authorizedRequest.value(forHTTPHeaderField: "Authorization")
        XCTAssertEqual(authorizationHeader, "Bearer testBearerToken")
    }
}
