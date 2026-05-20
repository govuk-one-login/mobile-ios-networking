import Foundation

/// Enables the NetworkClient and RequestBuilder to work together
public struct NetworkRequest {
    public var urlRequest: URLRequest
    public var authScope: String?
    public var requiresClientAttestations: Bool = false
    public var requiresDPoP: Bool = false
}
