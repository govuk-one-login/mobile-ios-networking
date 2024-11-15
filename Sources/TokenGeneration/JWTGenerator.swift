protocol JWTGenerator {
    func generate(
        header: [String: Any],
        payload: [String: Any]
    ) throws -> String
}
