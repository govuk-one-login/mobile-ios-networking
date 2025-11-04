@available(*, deprecated, message: "Please implement the JWTContent protocol directly")
public struct JWTRepresentation: JWTContent {
    public let header: [String: Any]
    public let payload: [String: Any]

    public init(header: [String: Any], payload: [String: Any]) {
        self.header = header
        self.payload = payload
    }
}
