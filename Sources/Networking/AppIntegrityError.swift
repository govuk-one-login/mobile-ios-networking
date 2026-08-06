import GDSUtilities

public enum AppIntegrityErrorKind: Int, GDSErrorKind {
    case generic = 1001
    case intermittent = 1002
    case appIntegrityFailed = 1003

    public var description: String {
        switch self {
        case .generic:
            return "generic error"
        case .intermittent:
            return "intermittent error like network or server"
        case .appIntegrityFailed:
            return "app integrity has failed"
        }
    }
}

public typealias AppIntegrityError = NetworkingGDSError<AppIntegrityErrorKind>

