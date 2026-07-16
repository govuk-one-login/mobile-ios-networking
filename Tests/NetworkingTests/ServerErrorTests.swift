import Foundation
@testable import Networking
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

    @Test("errorUserInfo includes response data when present")
    func errorUserInfoIncludesResponse() throws {
        // GIVEN: a ServerError with response data
        let responseData = Data("""
        {"error": "invalid_client"}
        """.utf8)
        let sut = ServerError(endpoint: "token", errorCode: 400, response: responseData)

        // WHEN: accessing userInfo via NSError bridging
        let nsError = sut as NSError

        // THEN: the response data is accessible
        let retrieved = try #require(nsError.userInfo["response"] as? Data)
        #expect(retrieved == responseData)
    }

    @Test("errorUserInfo is empty when response is nil")
    func errorUserInfoEmptyWhenNoResponse() {
        // GIVEN: a ServerError without response data
        let sut = ServerError(endpoint: "token", errorCode: 500)

        // WHEN: accessing userInfo via NSError bridging
        let nsError = sut as NSError

        // THEN: userInfo has no response key
        #expect(nsError.userInfo["response"] == nil)
    }
}
