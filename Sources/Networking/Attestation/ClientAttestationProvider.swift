/// Protocol for passing the client attestation headers
public protocol ClientAttestationProvider {
    func fetchClientAttestation() async throws -> [String: String]
}
