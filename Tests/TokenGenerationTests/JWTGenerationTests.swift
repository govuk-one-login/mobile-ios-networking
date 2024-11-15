@testable import TokenGeneration
import Testing

struct SignedJWTGeneratorTests {
    let mockSigner: MockSigner
    let sut: SignedJWTGenerator
    
    init() {
        self.mockSigner = MockSigner()
        self.sut = SignedJWTGenerator(signer: mockSigner)
    }
}
