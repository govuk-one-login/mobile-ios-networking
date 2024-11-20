import Foundation

extension Dictionary {
    var jsonData: Data {
        get throws {
            guard let jsonData = try? JSONSerialization.data(withJSONObject: self, options: .sortedKeys) else {
                throw JWTGeneratorError.cantCreateJSONData
            }
            return jsonData
        }
    }
}
