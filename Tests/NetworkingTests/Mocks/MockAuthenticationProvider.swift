@testable import Networking

actor MockAuthorizationProvider: AuthorizationProvider {
    private(set) var fetchedTokenScope: String?

    func fetchToken(withScope scope: String) async throws -> String {
        fetchedTokenScope = scope
        return "testBearerToken"
    }
}
