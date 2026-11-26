enum NetworkClientError: Error, Sendable {
    case authorizationProviderNotPresent
    case clientAttestationProviderNotPresent
    case dPoPProviderNotPresent
}
