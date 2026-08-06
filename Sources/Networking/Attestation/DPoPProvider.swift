/// Protocol for passing the dPoP headers
public protocol DPoPProvider {
    func fetchDPoP() async throws -> [String: String]
}
