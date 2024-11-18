@testable import TokenGeneration

struct MockJWTRepresentation: JWTRepresentation {
    var header: [String: Any]
    var payload: [String: Any]
}
