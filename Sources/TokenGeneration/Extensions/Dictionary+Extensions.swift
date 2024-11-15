import Foundation

extension Dictionary {
    var jsonData: Data {
        get throws {
            guard let jsonData = try? JSONSerialization.data(withJSONObject: self) else {
                throw SignedJWTGeneratorError.cantCreateJSONData
            }
            return jsonData
        }
    }
}
