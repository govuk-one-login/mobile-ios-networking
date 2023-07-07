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
        XCTAssertEqual(sut.parameters["endpoint"], "testendpoint")
        XCTAssertEqual(sut.parameters["code"]?.description, "200")
        XCTAssertEqual(sut.parameters["reason"], "server")
        XCTAssertEqual(sut.hash, "83766358f64858b51afb745bbdde91bb")
    }
}
