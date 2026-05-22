import Foundation

/// Make sure all NetworkClient Wrappers extend this protocol
public protocol NetworkClientProtocol {
    func request(_ request: URLRequest) -> RequestBuilder
    func makeRequest(_ request: NetworkRequest) async throws -> Data
}

/// Default implementation so that it's not repeated on each NetworkClient wrapper
extension NetworkClientProtocol {
    /// Accepts a URLRequest and creates a RequestBuilder with reference to the NetworkClient itself.
    /// The builder makes a NetworkRequest it can modify further, which will be used by makeRequest(), invoked from the .execute() on the builder.
    public func request(_ request: URLRequest) -> RequestBuilder {
        RequestBuilder(client: self, request: request)
    }
}
