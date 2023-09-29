/// Protocol for passing a bearer token for authentication
public protocol AuthenticationProvider {
    var bearerToken: String { get async throws }
}
