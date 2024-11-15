protocol JWTGenerator {
    func generate(
        header: [String: String],
        payload: [String: String]
    ) throws -> String
}
