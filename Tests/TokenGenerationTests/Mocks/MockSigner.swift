import Foundation
@testable import TokenGeneration

struct MockSigner: SigningService {
    func sign(data: Data) throws -> Data {
        data
    }
}
