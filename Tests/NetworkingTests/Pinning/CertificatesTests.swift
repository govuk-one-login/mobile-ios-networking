@testable import Networking
import XCTest

final class CertificatesTests: XCTestCase {
    func test_certificates_presentInBundle() {
        Certificates.allCases.forEach {
            XCTAssertNotNil($0.data)
        }
    }
}
