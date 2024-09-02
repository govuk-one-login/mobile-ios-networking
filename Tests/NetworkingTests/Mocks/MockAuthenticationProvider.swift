import Foundation
@testable import Networking

final class MockAuthorizationProvider: AuthorizationProvider {
    private(set) var fetchedTokenScope: String?

    func fetchToken(withScope scope: String) async throws -> String {
        fetchedTokenScope = scope
        return "testBearerToken"
    }
}
