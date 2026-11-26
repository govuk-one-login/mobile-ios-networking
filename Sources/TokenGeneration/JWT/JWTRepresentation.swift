@available(*, deprecated, message: "Please implement the JWTContent protocol directly")
public struct JWTRepresentation: JWTContent {
    public let header: [String: any Sendable]
    public let payload: [String: any Sendable]

    public init(header: [String: any Sendable], payload: [String: any Sendable]) {
        self.header = header
        self.payload = payload
    }
}
