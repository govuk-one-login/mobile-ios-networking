import Foundation
@testable import Networking
import XCTest

final class RequestBuilderTests: XCTestCase {
    // NetworkClient Mock
    private actor MockNetworkClient: NetworkClientProtocol {
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
    func test_authentication_request() async {
        // No auth scope set by default
        let initialAuthScope = await sut.request.authScope
        XCTAssertNil(initialAuthScope)
        
        // Make sure request has an authscope
        let newSut = await sut.withAuthentication(scope: "test_auth_scope")
        let currentAuthScope = await newSut.request.authScope
        XCTAssertEqual(currentAuthScope, "test_auth_scope")
    }
    
    func test_attestation_request() async {
        // No auth scope set by default
        let initialClientAttestation = await sut.request.requiresClientAttestation
        XCTAssertFalse(initialClientAttestation)
        
        // Make sure request has an authscope
        let newSut = await sut.withClientAttestation()
        let currentClientAttestation = await newSut.request.requiresClientAttestation
        XCTAssertTrue(currentClientAttestation)
        let currentDPoP = await newSut.request.requiresDPoP
        XCTAssertFalse(currentDPoP)
    }
    
    func test_dPoP_request() async {
        // DPoP set by default
        let inititalDPoP = await sut.request.requiresDPoP
        XCTAssertFalse(inititalDPoP)
        
        let newSut = await sut.withDPoP()
        let currentDPoP = await newSut.request.requiresDPoP
        // Make sure request requires DPoP
        XCTAssertTrue(currentDPoP)
        
        let currentClientAttestation = await newSut.request.requiresClientAttestation
        XCTAssertFalse(currentClientAttestation)
    }
    
    func test_execute_request() async throws {
        let data = try await sut.execute()

        XCTAssertEqual(data, Data())
        // Make sure execute calls makeRequest on the NetworkClient its invoked
        let receivedRequest = await mockNetworkClient.receivedRequest?.urlRequest
        XCTAssertEqual(receivedRequest, URLRequest.example)
    }
    
    func test_example_call() async {
        let initialClientAttestation = await sut.request.requiresClientAttestation
        let inititalDPoP = await sut.request.requiresDPoP
        let initialAuthScope = await sut.request.authScope
        XCTAssertFalse(initialClientAttestation)
        XCTAssertFalse(inititalDPoP)
        XCTAssertNil(initialAuthScope)
        
        let requestBuilder = await sut
            .withAuthentication(scope: "testAuth")
            .withClientAttestation()
            .withDPoP()
        
        // Make sure request has all the set parameters
        let clientAttestation = await requestBuilder.request.requiresClientAttestation
        let dPoP = await sut.request.requiresDPoP
        let authScope = await sut.request.authScope
        XCTAssertTrue(clientAttestation)
        XCTAssertTrue(dPoP)
        XCTAssertEqual(authScope, "testAuth")
    }
}
