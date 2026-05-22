@testable import Networking
import XCTest

final class URLRequestTests: XCTestCase {
    func test_authorized() throws {
        let authorizedRequest = URLRequest.example
            .authorized(with: "testBearerToken")
        let authorizationHeader = authorizedRequest.value(forHTTPHeaderField: "Authorization")
        XCTAssertEqual(authorizationHeader, "Bearer testBearerToken")
    }
    
    func test_header_insertion() throws {
        let assertionRequest = URLRequest.example
            .setHeaderValues(["testClientAttestation": "12345",
                              "testPoP": "12345"])
        let assertionHeader = assertionRequest.value(forHTTPHeaderField: "testClientAttestation")
        XCTAssertEqual(assertionHeader, "12345")
        let assertionPoPHeader = assertionRequest.value(forHTTPHeaderField: "testPoP")
        XCTAssertEqual(assertionPoPHeader, "12345")
    }
}
