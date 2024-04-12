import Combine
import Foundation

/// NetworkClient
///
/// `NetworkClient` is a class with one public async throwing method called `makeRequest` which handles network requests and returns `Data`.
public final class NetworkClient {
    private let session: URLSession
    private let authenticationProvider: AuthenticationProvider?
    private var cancellables: Set<AnyCancellable> = []
    
    /// Convenience initialiser that uses the `URLSessionConfiguration.ephemeral` singleton
    public convenience init(authenticationProvider: AuthenticationProvider? = nil) {
        self.init(configuration: .ephemeral,
                  authenticationProvider: authenticationProvider)
    }
    
    /// Initialiser sets the `URLSessionConfiguration` and certificate pinning.
    ///
    /// For iOS 14 and later, certificates are pinned using `NSAppTransportSecurity`.
    /// Earlier versions of iOS use `SSLPinningDelegate` which conforms to `URLSessionDelegate` protocol to handle certificate pinning.
    ///
    /// - Parameters:
    ///   - configuration: URLSessionConfiguration
    ///   - authenticationProvider: Provider of bearer token to network request
    ///
    init(configuration: URLSessionConfiguration,
         authenticationProvider: AuthenticationProvider? = nil) {
        self.authenticationProvider = authenticationProvider
        
        configuration.tlsMinimumSupportedProtocolVersion = .TLSv12
        configuration.httpAdditionalHeaders = ["User-Agent": UserAgent().description]
        #if DEBUG
        print(configuration.httpAdditionalHeaders!)
        #endif
        if #available(iOS 14, *) {
            // On iOS 14+, certificate pinning is handled by NSAppTransportSecurity
            // https://developer.apple.com/documentation/bundleresources/information_property_list/nsapptransportsecurity
            session = .init(configuration: configuration)
        } else {
            let queue = OperationQueue()
            queue.underlyingQueue = .global()
            
            let delegate = SSLPinningDelegate()
            
            session = .init(configuration: configuration,
                            delegate: delegate,
                            delegateQueue: queue)
        }
    }
    
    /// `makeAuthorizedRequest` method for making authenticated network requests has three parameters and returns `Data`
    ///  the network client must be initialised with an authenticationProvider else an error is thrown
    ///
    /// - Parameters:
    ///   - exchangeRequest: ``URLRequest`` for the token exchange network request
    ///   - scope: ``String`` for the scope of the authorized token
    ///   - request: ``URLRequest`` for the authenticated network request
    /// - Returns: ``Data`` the response data from the endpoint
    public func makeAuthorizedRequest(exchangeRequest: URLRequest,
                                      scope: String,
                                      request: URLRequest) async throws -> Data {
        let serviceToken = try await exchangeToken(exchangeRequest: exchangeRequest, scope: scope)
        let authorizedRequest = request.authorized(with: serviceToken.accessToken)
        return try await makeRequest(authorizedRequest)
    }
    
    func exchangeToken(exchangeRequest: URLRequest, scope: String) async throws -> ServiceTokenResponse {
        guard let authenticationProvider else {
            assertionFailure("Authentication provider not present")
            throw NetworkClientError.authenticationProviderNotPresent
        }
        let subjectToken = try await authenticationProvider.bearerToken
        let serviceTokenRequest = exchangeRequest.tokenExchange(subjectToken: subjectToken,
                                                                scope: scope)
        let serviceTokenResponse = try await makeRequest(serviceTokenRequest)
        return try decodeServiceToken(data: serviceTokenResponse)
    }
    
    func decodeServiceToken(data: Data) throws -> ServiceTokenResponse {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            return try jsonDecoder.decode(ServiceTokenResponse.self,
                                          from: data)
        } catch {
            throw NetworkClientError.unableToDecodeServiceTokenResponse
        }
    }
    
    /// `makeRequest` method for making network requests has a single parameter of type `URLRequest` and returns `Data`
    ///
    /// - Parameters:
    ///   - request: ``URLRequest`` for the network request
    /// - Returns: ``Data`` the response data from the endpoint
    public func makeRequest(_ request: URLRequest) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            makeRequest(request) { response in
                switch response {
                case .success((let data, let response as HTTPURLResponse)):
                    #if DEBUG
                    print("network status code: \(response.statusCode)")
                    print("absolute path", response.url?.absoluteString ?? "")
                    print("last path component", response.url?.pathComponents.last ?? "")
                    #endif
                    guard response.isSuccessful else {
                        continuation.resume(throwing: ServerError(endpoint: request.url?.pathComponents.last, errorCode: response.statusCode))
                        return
                    }
                    continuation.resume(returning: data)
                case .success((let data, _)):
                    continuation.resume(returning: data)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func makeRequest(_ request: URLRequest,
                             completion: @escaping (Result<(Data, URLResponse), Error>) -> Void) {
        session.dataTaskPublisher(for: request).sink {
            if case .failure(let error) = $0 {
                completion(.failure(error))
            }
        } receiveValue: {
            completion(.success(($0, $1)))
        }.store(in: &cancellables)
    }
}
