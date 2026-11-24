public enum JWTGeneratorError: Error, Sendable {
    case cantCreateJSONData
    case cantCreateJSONString
}
