/// Protocol for passing the dPoP headers
public protocol DPoPProvider: Sendable {
    func fetchDPoP() async throws -> [String: String]
}
