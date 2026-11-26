import Foundation.NSData

public protocol JWTSigningService: Sendable {
    func sign(data: Data) throws -> Data
}
