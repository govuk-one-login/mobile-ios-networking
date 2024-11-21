import Foundation
@testable import TokenGeneration

struct MockJWTSigningService: JWTSigningService {
    func sign(data: Data) throws -> Data {
        data
    }
}
