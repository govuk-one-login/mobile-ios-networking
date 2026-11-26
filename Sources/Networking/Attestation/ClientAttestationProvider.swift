/// Protocol for passing the client attestation headers
public protocol ClientAttestationProvider: Sendable {
    func fetchClientAttestation() async throws -> [String: String]
}
