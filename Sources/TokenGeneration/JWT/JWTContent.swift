public protocol JWTContent: Sendable {
    var header: [String: any Sendable] { get }
    var payload: [String: any Sendable] { get }
}
