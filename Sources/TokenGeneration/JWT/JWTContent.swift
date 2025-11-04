public protocol JWTContent {
    var header: [String: Any] { get }
    var payload: [String: Any] { get }
}
