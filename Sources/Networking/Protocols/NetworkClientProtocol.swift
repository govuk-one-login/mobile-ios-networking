import Foundation

/// Make sure all NetworkClient Wrappers extend this protocol
public protocol NetworkClientProtocol {
    func request(_ request: URLRequest) -> RequestBuilder
    func makeRequest(_ request: NetworkRequest) async throws -> Data
}

/// Provide implementation so that we don't have to repeat it on each NetworkClient
extension NetworkClientProtocol {
    /// Enables building a request that the builder can modify
    public func request(_ request: URLRequest) -> RequestBuilder {
        RequestBuilder(client: self, request: request)
    }
}
