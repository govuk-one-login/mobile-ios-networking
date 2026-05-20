@testable import Networking
import XCTest

final class URLRequestTests: XCTestCase {
    func test_authorized() throws {
        let authorizedRequest = URLRequest.example
            .authorized(with: "testBearerToken")
        let authorizationHeader = authorizedRequest.value(forHTTPHeaderField: "Authorization")
        XCTAssertEqual(authorizationHeader, "Bearer testBearerToken")
    }
    
    func test_client_assertions() throws {
        let assertionRequest = URLRequest.example
            .clientAttestation(with: ["testClientAttestation": "12345",
                                      "testPoP": "12345"])
        let assertionHeader = assertionRequest.value(forHTTPHeaderField: "testClientAttestation")
        XCTAssertEqual(assertionHeader, "12345")
        let assertionPoPHeader = assertionRequest.value(forHTTPHeaderField: "testPoP")
        XCTAssertEqual(assertionPoPHeader, "12345")
    }
    
    func test_dPoP() throws {
        let dPoPRequest = URLRequest.example
            .dPoPAssertion(with: ["testDPoP": "12345"])
        let dPoPHeader = dPoPRequest.value(forHTTPHeaderField: "testDPoP")
        XCTAssertEqual(dPoPHeader, "12345")
    }
}
