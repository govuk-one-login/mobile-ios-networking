import Foundation

extension URLRequest {
    func clientAttestation(with clientAttestationValues: [String: String]) -> Self {
        var request = self
        for (key, value) in clientAttestationValues {
            request.setValue(
                value,
                forHTTPHeaderField: key
            )
        }
        return request
    }
    
    func dPoPAssertion(with dPoPValues: [String: String]) -> Self {
        var request = self
        for (key, value) in dPoPValues {
            request.setValue(
                value,
                forHTTPHeaderField: key
            )
        }
        return request
    }
}
