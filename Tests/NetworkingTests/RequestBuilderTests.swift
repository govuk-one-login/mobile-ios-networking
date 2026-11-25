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
        let authScope = await newSut.request.authScope
        XCTAssertEqual(authScope, "test_auth_scope")
    }
    
    func test_attestation_request() async {
        // Client attestation is not required by default
        let initialRequiresClientAttestation = await sut.request.requiresClientAttestation
        XCTAssertFalse(initialRequiresClientAttestation)
        
        // Make sure request requires client attestation
        let newSut = await sut.withClientAttestation()
        let requiresClientAttestation = await newSut.request.requiresClientAttestation
        let requiresDPoP = await newSut.request.requiresDPoP
        XCTAssertTrue(requiresClientAttestation)
        XCTAssertFalse(requiresDPoP)
    }
    
    func test_dPoP_request() async {
        // DPoP is not required by default
        let initialRequiresDPoP = await sut.request.requiresDPoP
        XCTAssertFalse(initialRequiresDPoP)
        
        // Make sure request requires DPoP
        let newSut = await sut.withDPoP()
        let requiresDPoP = await newSut.request.requiresDPoP
        let requiresClientAttestation = await newSut.request.requiresClientAttestation
        XCTAssertTrue(requiresDPoP)
        XCTAssertFalse(requiresClientAttestation)
    }
    
    func test_execute_request() async throws {
        let data = try await sut.execute()

        XCTAssertEqual(data, Data())
        // Make sure execute calls makeRequest on the NetworkClient its invoked
        let receivedRequest = await mockNetworkClient.receivedRequest?.urlRequest
        XCTAssertEqual(receivedRequest, URLRequest.example)
    }
    
    func test_example_call() async {
        let initialRequiresClientAttestation = await sut.request.requiresClientAttestation
        let initialRequiresDPoP = await sut.request.requiresDPoP
        let initialAuthScope = await sut.request.authScope
        XCTAssertFalse(initialRequiresClientAttestation)
        XCTAssertFalse(initialRequiresDPoP)
        XCTAssertNil(initialAuthScope)
        
        let requestBuilder = await sut
            .withAuthentication(scope: "testAuth")
            .withClientAttestation()
            .withDPoP()
        
        // Make sure request has all the set parameters
        let requiresClientAttestation = await requestBuilder.request.requiresClientAttestation
        let requiresDPoP = await requestBuilder.request.requiresDPoP
        let authScope = await requestBuilder.request.authScope
        XCTAssertTrue(requiresClientAttestation)
        XCTAssertTrue(requiresDPoP)
        XCTAssertEqual(authScope, "testAuth")
    }
}
