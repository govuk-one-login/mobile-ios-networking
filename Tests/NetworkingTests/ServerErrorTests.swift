@testable import Networking
import XCTest

final class ServerErrorTests: XCTestCase {
    private var sut: ServerError!

    override func setUp() {
        super.setUp()
        sut = ServerError(endpoint: "testendpoint", errorCode: 200)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_ServerError_params() throws {
        XCTAssertEqual(sut.endpoint, "testendpoint")
        XCTAssertEqual(sut.errorCode.description, "200")
        XCTAssertEqual(sut.reason, "server")
        XCTAssertEqual(sut.hash, "83766358f64858b51afb745bbdde91bb")
    }
}
