/// Protocol for passing the dPoP headers
public protocol DPoPProvider {
    func fetchDPoP() async throws(AppIntegrityError) -> [String: String]
}
