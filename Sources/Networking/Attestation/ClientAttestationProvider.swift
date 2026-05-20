/// Protocol for passing the client attestation headers
public protocol ClientAttestationProvider {
    func fetchClientAttestations() async throws -> [String: String]
    func fetchDPoP() throws -> [String: String]
}
