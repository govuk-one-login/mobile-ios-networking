import Foundation

protocol SigningService {
    func sign(data: Data) throws -> Data
}
