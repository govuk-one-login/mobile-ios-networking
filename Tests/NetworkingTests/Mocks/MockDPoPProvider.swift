import Foundation
@testable import Networking

final class MockDPoPProvider: DPoPProvider {
    func fetchDPoP() async throws -> [String: String] {
        return ["Test-DPoP": "12345"]
    }
}
