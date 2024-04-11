import Combine
import Foundation

enum NetworkClientError: Error {
    case authenticationProviderNotPresent
    case unableToDecodeServiceTokenResponse
}

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
    
    /// if network client has been passed authenticationProvider then request will include bearer token in header
    public func makeAuthorizedRequest(_ request: URLRequest, scope: String? = nil) async throws -> Data {
        switch scope {
        case .some(let scope):
            // Make request to /token endpoint for service token
            guard let authenticationProvider else {
                assertionFailure("Authentication provider not present")
                throw NetworkClientError.authenticationProviderNotPresent
            }
            let subjectToken = try await authenticationProvider.bearerToken
            let serviceTokenRequest = URLRequest.tokenExchange(url: URL(string: "/token")!,
                                                               subjectToken: subjectToken,
                                                               scope: scope)
            let serviceTokenResponse = try await makeRequest(serviceTokenRequest)
            let jsonDecoder = JSONDecoder()
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
            let serviceToken: ServiceTokenResponse
            do {
                serviceToken = try jsonDecoder.decode(ServiceTokenResponse.self, from: serviceTokenResponse)
            } catch {
                throw NetworkClientError.unableToDecodeServiceTokenResponse
            }
            
            // attach service token to request
            let authorizedRequest = request
                .authorized(with: serviceToken.accessToken)
            // make request
            return try await makeRequest(authorizedRequest)
        case .none:
            return try await makeRequest(request)
        }
    }
    
    /// `makeRequest` method for making network requests has a single parameter of type `URLRequest` and returns `Data`
    ///
    /// - Parameters:
    ///   - request: ``URLRequest`` for the network request
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
