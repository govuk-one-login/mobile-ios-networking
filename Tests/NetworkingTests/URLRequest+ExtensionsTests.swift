@testable import Networking
import XCTest

final class URLRequestTests: XCTestCase {
    func test_authorized() throws {
        let authorizedRequest = URLRequest.example
            .authorized(with: "testBearerToken")
        let authorizationHeader = authorizedRequest.value(forHTTPHeaderField: "Authorization")
        XCTAssertEqual(authorizationHeader, "Bearer testBearerToken")
    }
}
