public struct JWTRepresentation {
    let header: [String: Any]
    let payload: [String: Any]
    
    public init(header: [String: Any], payload: [String: Any]) {
        self.header = header
        self.payload = payload
    }
}
