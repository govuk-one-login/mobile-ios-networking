import Foundation

public protocol JWTSigningService {
    func sign(data: Data) throws -> Data
}
