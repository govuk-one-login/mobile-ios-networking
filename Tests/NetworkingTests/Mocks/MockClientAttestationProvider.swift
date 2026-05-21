import Foundation
@testable import Networking

final class MockClientAttestationProvider: ClientAttestationProvider {
    func fetchClientAttestation() async throws -> [String: String] {
        return ["Test-Client-Attestation": "12345",
                "Test-Client-Attestation-PoP": "12345"]
    }
    
    func fetchDPoP() throws -> [String: String] {
        return ["Test-DPoP": "12345"]
    }
}
