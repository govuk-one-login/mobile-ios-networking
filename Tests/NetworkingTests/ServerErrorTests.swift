@testable import Networking
import Foundation
import Testing

struct ServerErrorTests {
    @Test("ServerError params")
    func serverError_params() throws {
        let sut = ServerError(endpoint: "testendpoint", errorCode: 200)
        
        #expect(sut.endpoint == "testendpoint")
        #expect(sut.errorCode.description == "200")
        #expect(sut.reason == "server")
        #expect(sut.hash == "83766358f64858b51afb745bbdde91bb")
    }
    
    @Test("ServerError as CustomNSError")
    func castAsCustomNSError() throws {
        let sut = ServerError(endpoint: "testendpoint", errorCode: 200)
        
        let nsError = sut as CustomNSError
        
        #expect(nsError.errorCode == 200)
    }
}
