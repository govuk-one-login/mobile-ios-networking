import Foundation

/// Enables the NetworkClient and RequestBuilder to work together
public struct NetworkRequest {
    public var urlRequest: URLRequest
    public var authScope: String?
    public var requiresClientAttestation: Bool
    public var requiresDPoP: Bool
    
    public init(
        urlRequest: URLRequest,
        authScope: String? = nil,
        requiresClientAttestation: Bool = false,
        requiresDPoP: Bool = false
    ) {
        self.urlRequest = urlRequest
        self.authScope = authScope
        self.requiresClientAttestation = requiresClientAttestation
        self.requiresDPoP = requiresDPoP
    }
}
