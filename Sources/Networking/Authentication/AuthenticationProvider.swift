public protocol AuthenticationProvider {
    var bearerToken: String { get async throws }
}
