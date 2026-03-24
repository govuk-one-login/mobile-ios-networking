import Foundation

/// NetworkClient
///
/// `NetworkClient` is a class with one public async throwing method called `makeRequest` which handles network requests and returns `Data`.
public final class NetworkClient {
    public var authorizationProvider: AuthorizationProvider?

    private let session: URLSession
    
    #if DEBUG
        var debugSession: URLSession {
            session
        }
    #endif
    
    /// Convenience initialiser that uses the `URLSessionConfiguration.default` singleton
    public convenience init() {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .useProtocolCachePolicy
        self.init(configuration: config)
    }
    
    /// Initialiser sets the `URLSessionConfiguration` and certificate pinning.
    ///
    /// For iOS 14 and later, certificates are pinned using `NSAppTransportSecurity`.
    /// Earlier versions of iOS use `SSLPinningDelegate` which conforms to `URLSessionDelegate` protocol to handle certificate pinning.
    ///
    /// - Parameters:
    ///   - configuration: URLSessionConfiguration
    ///
    init(configuration: URLSessionConfiguration) {
        configuration.tlsMinimumSupportedProtocolVersion = .TLSv12
        configuration.httpAdditionalHeaders = ["User-Agent": UserAgent().description]
        #if DEBUG
        print(configuration.httpAdditionalHeaders!)
        #endif
        session = .init(configuration: configuration)
    }
    
    /// `makeRequest` method for making network requests has a single parameter of type `URLRequest` and returns `Data`
    ///
    /// - Parameters:
    ///   - request: ``URLRequest`` for the network request
    /// - Returns: ``Data`` the response data from the endpoint
    public func makeRequest(_ request: URLRequest) async throws -> Data {
        let (data, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            #if DEBUG
            print("network status code: \(httpResponse.statusCode)")
            print("absolute path", httpResponse.url?.absoluteString ?? "")
            print("last path component", httpResponse.url?.pathComponents.last ?? "")
            #endif
            guard httpResponse.isSuccessful else {
                throw ServerError(endpoint: request.url?.pathComponents.last,
                                  errorCode: httpResponse.statusCode,
                                  response: data)
            }
        }
        
        return data
    }

    /// `makeAuthorizedRequest` method for making authorized network requests has three parameters and returns `Data`
    ///  the network client must be initialised with an authorizationProvider else an error is thrown
    ///
    /// - Parameters:
    ///   - scope: ``String`` for the scope of the authenticated token
    ///   - request: ``URLRequest`` for the authorized network request
    /// - Returns: ``Data`` the response data from the endpoint
    public func makeAuthorizedRequest(
        scope: String,
        request: URLRequest
    ) async throws -> Data {
        guard let authorizationProvider else {
            assertionFailure("Authorization provider not present")
            throw NetworkClientError.authorizationProviderNotPresent
        }

        let authorizationToken = try await authorizationProvider
            .fetchToken(withScope: scope)

        let authorizedRequest = request.authorized(with: authorizationToken)
        
        return try await makeRequest(authorizedRequest)
    }
}
