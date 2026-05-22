/// Protocol for passing the dPoP headers
public protocol DPoPProvider {
    func fetchDPoP() throws -> [String: String]
}
