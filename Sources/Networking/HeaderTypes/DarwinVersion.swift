import Foundation

/// DarwinVersion
///
/// A type for fetching the current `Darwin` version used as part of the operating system. Used to assemble the `UserAgent` HTTP header.
struct DarwinVersion: CustomStringConvertible {
    var description: String {
        "Darwin/\(darwinVersion)"
    }
    
    private var darwinVersion: Version {
        var sysinfo = utsname()
        uname(&sysinfo)
        
        guard let versionString = String(bytes: Data(bytes: &sysinfo.release,
                                                     count: Int(_SYS_NAMELEN)),
                                         encoding: .ascii)?.trimmingCharacters(in: .controlCharacters),
              let version = Version(string: versionString) else {
            return .one
        }
        return version
    }
}
