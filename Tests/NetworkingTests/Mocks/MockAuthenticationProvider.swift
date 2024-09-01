import Foundation
@testable import Networking

final class MockAuthorizationProvider: AuthorizationProvider {
    private(set) var didFetchToken: String?

    func fetchToken(withScope scope: String) async throws -> String {
        didFetchToken = scope
        return "testBearerToken"
    }
}
