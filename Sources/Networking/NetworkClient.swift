import Foundation

/// NetworkClient
///
/// `NetworkClient` is a class with one public async throwing method called `makeRequest` which handles network requests and returns `Data`.
///
///  NetworkClient wrappers need to extend NetworkClientProtocol so that the execute() on the builder goes through the makeRequest they are implementing.
public final class NetworkClient: NetworkClientProtocol {
    public var authorizationProvider: AuthorizationProvider?
    public var clientAttestationProvider: ClientAttestationProvider?
    public var dPoPProvider: DPoPProvider?
    
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
    
    /// `makeRequest` method for making network requests has a single parameter of type `NetworkRequest` and returns `Data`
    ///  Meant to be used through the .execute() function and not to be called directly
    ///  Example:
    ///  networkClient.request(URLRequest).withAuthentication().withClientAttestation().withDPoP().execute()
    ///
    /// - Parameters:
    ///   - request: ``NetworkRequest`` for the network request
    /// - Returns: ``Data`` the response data from the endpoint
    public func makeRequest(_ request: NetworkRequest) async throws -> Data {
        let urlRequest = try await configureRequestHeaders(for: request)
 
        let (data, response) = try await session.data(for: urlRequest)
        
        if let httpResponse = response as? HTTPURLResponse {
            #if DEBUG
            print("network status code: \(httpResponse.statusCode)")
            print("absolute path", httpResponse.url?.absoluteString ?? "")
            print("last path component", httpResponse.url?.pathComponents.last ?? "")
            #endif
            guard httpResponse.isSuccessful else {
                throw ServerError(endpoint: urlRequest.url?.pathComponents.last,
                                  errorCode: httpResponse.statusCode,
                                  response: data)
            }
        }
        
        return data
    }
    
    private func configureRequestHeaders(for request: NetworkRequest) async throws -> URLRequest {
        var urlRequest = request.urlRequest
        
        /// Add authorization header if auth scope provided
        if let scope = request.authScope {
            guard let authorizationProvider else {
                assertionFailure("Authorization provider not present")
                throw NetworkClientError.authorizationProviderNotPresent
            }
            let authorizationToken = try await authorizationProvider.fetchToken(withScope: scope)
            urlRequest = urlRequest.authorized(with: authorizationToken)
        }
        
        /// Add client attestation headers if required
        if request.requiresClientAttestation {
            guard let clientAttestationProvider else {
                assertionFailure("Client attestation provider not present")
                throw NetworkClientError.clientAttestationProviderNotPresent
            }
            let attestationHeaders = try await clientAttestationProvider.fetchClientAttestation()
            urlRequest = urlRequest.setHeaderValues(attestationHeaders)
        }
        
        /// Add DPoP header if required
        if request.requiresDPoP {
            guard let dPoPProvider else {
                assertionFailure("DPoP provider not present")
                throw NetworkClientError.dPoPProviderNotPresent
            }
            let dPoPHeaders = try await dPoPProvider.fetchDPoP()
            urlRequest = urlRequest.setHeaderValues(dPoPHeaders)
        }
        
        return urlRequest
    }
}

// TODO: DCMAW-20369 Remove deprecated methods
extension NetworkClient {
    /// `makeRequest` method for making network requests has a single parameter of type `URLRequest` and returns `Data`
    ///
    /// - Parameters:
    ///   - request: ``URLRequest`` for the network request
    /// - Returns: ``Data`` the response data from the endpoint
    @available(*, deprecated, message: "Use .request().execute() instead")
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
    @available(*, deprecated, message: "Use .request().withAuthorization(scope:).execute() instead")
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
