/// Protocol for passing a bearer token for authorization
public protocol AuthorizationProvider {
    func fetchToken(withScope scope: String) async throws -> String
}
