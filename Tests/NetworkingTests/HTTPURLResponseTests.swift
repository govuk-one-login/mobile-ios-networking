import MockNetworking
@testable import Networking
import XCTest

final class HTTPURLResponseTests: XCTestCase {
    func testIsSuccessful() {
        (0...199).forEach {
            XCTAssertFalse(HTTPURLResponse(statusCode: $0).isSuccessful)
        }
        (200...299).forEach {
            XCTAssertTrue(HTTPURLResponse(statusCode: $0).isSuccessful)
        }
        (300...500).forEach {
            XCTAssertFalse(HTTPURLResponse(statusCode: $0).isSuccessful)
        }
    }
}
