import Foundation

/// Provides helper methods for constructing requests
public final class RequestBuilder {
    private var networkClient: NetworkClientProtocol
    var request: NetworkRequest
    
    public init(client: NetworkClientProtocol, request: URLRequest) {
        self.networkClient = client
        self.request = NetworkRequest(urlRequest: request)
    }
    
    public func withAuthentication(scope: String) -> RequestBuilder {
        request.authScope = scope
        return self
    }
    
    public func withClientAttestation() -> RequestBuilder {
        request.requiresClientAttestation = true
        return self
    }
    
    public func withDPoP() -> RequestBuilder {
        request.requiresDPoP = true
        return self
    }
    
    public func execute() async throws -> Data {
        try await networkClient.makeRequest(request)
    }
}
