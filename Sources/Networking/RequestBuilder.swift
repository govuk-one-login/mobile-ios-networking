import Foundation

/// Provides helper methods for constructing requests
public struct RequestBuilder: Sendable {
    private let networkClient: NetworkClientProtocol
    var request: NetworkRequest
    
    public init(client: NetworkClientProtocol, request: URLRequest) {
        self.networkClient = client
        self.request = NetworkRequest(urlRequest: request)
    }
    
    public mutating func withAuthentication(scope: String) -> RequestBuilder {
        request.authScope = scope
        return self
    }
    
    public mutating func withClientAttestation() -> RequestBuilder {
        request.requiresClientAttestation = true
        return self
    }
    
    public mutating func withDPoP() -> RequestBuilder {
        request.requiresDPoP = true
        return self
    }
    
    public func execute() async throws -> Data {
        try await networkClient.makeRequest(request)
    }
}
