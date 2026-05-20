import Foundation
@testable import Networking
import XCTest


final class RequestBuilderTests: XCTestCase {
    // NetworkClient Mock
    private final class MockNetworkClient: NetworkClientProtocol {
        var receivedRequest: NetworkRequest?
        
        func makeRequest(_ request: NetworkRequest) async throws -> Data {
            receivedRequest = request
            return Data()
        }
    }
    
    private var sut: RequestBuilder!
    private var mockNetworkClient: MockNetworkClient!
    
    override func setUp() {
        super.setUp()
        mockNetworkClient = MockNetworkClient()
        sut = RequestBuilder(client: mockNetworkClient, request: URLRequest.example)
    }
    
    override func tearDown() {
        sut = nil
        mockNetworkClient = nil
        super.tearDown()
    }
}

extension RequestBuilderTests {    
    func test_authentication_request() {
        // No auth scope set by default
        XCTAssertNil(sut.request.authScope)
        
        // Make sure request has an authscope
        let newSut = sut.withAuthentication(scope: "test_auth_scope")
        XCTAssertEqual(newSut.request.authScope, "test_auth_scope")
    }
    
    func test_attestation_request() {
        // No auth scope set by default
        XCTAssertFalse(sut.request.requiresClientAttestations)
        
        // Make sure request has an authscope
        let newSut = sut.withAttestation()
        XCTAssertTrue(newSut.request.requiresClientAttestations)
        XCTAssertFalse(newSut.request.requiresDPoP)
    }
    
    func test_dPoP_request() {
        // No auth scope set by default
        XCTAssertFalse(sut.request.requiresDPoP)
        
        // Make sure request has an authscope
        let newSut = sut.withDPoP()
        XCTAssertTrue(newSut.request.requiresDPoP)
        XCTAssertFalse(newSut.request.requiresClientAttestations)
    }
    
    func test_execute_request() async throws {
        let data = try await sut.execute()

        XCTAssertEqual(data, Data())
        // Make sure execute calls makeRequest on the NetworkClient its invoked
        XCTAssertEqual(mockNetworkClient.receivedRequest?.urlRequest, URLRequest.example)
    }
    
    func test_example_call() {
        XCTAssertFalse(sut.request.requiresClientAttestations)
        XCTAssertFalse(sut.request.requiresDPoP)
        XCTAssertNil(sut.request.authScope)
        
        let requestBuilder = sut
            .withAuthentication(scope: "testAuth")
            .withAttestation()
            .withDPoP()
        
        // Make sure request has all the set parameters
        XCTAssertTrue(requestBuilder.request.requiresClientAttestations)
        XCTAssertTrue(requestBuilder.request.requiresDPoP)
        XCTAssertEqual(requestBuilder.request.authScope, "testAuth")
    }
}
