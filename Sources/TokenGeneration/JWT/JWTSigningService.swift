import Foundation.NSData

public protocol JWTSigningService {
    func sign(data: Data) throws -> Data
}
