enum NetworkClientError: Error {
    case authorizationProviderNotPresent
    case clientAttestationProviderNotPresent
    case dPoPProviderNotPresent
}
