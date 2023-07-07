import UIKit

/// UserAgent
///
/// A type to collect and structure user and device data to send in the HTTP header `User-Agent` parameter.
struct UserAgent: CustomStringConvertible {
    
    private let app: AppBundle
    private let deviceModel: String
    private let device: Device
    private let cfApp: AppBundle?
    private let darwin: String
    
    
    /// - Parameters:
    ///   - id: The Session ID for the Read ID session, created by the Read ID SDK.
    ///
    ///  - `app`  of type `AppBundle` and defaults the argument to `Bundle.main`
    ///  - `deviceModel` of type `String` and defaults to that returned from `DeviceModel`
    ///  - `device` of type `Device` and defaults to that returned from `UIDevice.current`
    ///  - `cfapp` of type optional `AppBundle` and defaults to that returned from `Bundle(identifier: "com.apple.CFNetwork")`
    ///  - `darwin` of type `String` and defaults to that returned from `DarwinVersion`
    init(app: AppBundle = Bundle.main,
         deviceModel: String = DeviceModel().description,
         device: Device = UIDevice.current,
         cfapp: AppBundle? = Bundle(identifier: "com.apple.CFNetwork"),
         darwin: String = DarwinVersion().description) {
        self.app = app
        self.deviceModel = deviceModel
        self.device = device
        self.cfApp = cfapp
        self.darwin = darwin
    }
    
    // MARK: Creating the App Name and Version string
    private var appName: String {
        guard let appName = retrieveFromInfoDictionary(key: "CFBundleName")?
            .replacingOccurrences(of: " ", with: "_") else {
            return "Unknown_name"
        }
        return appName
    }
    
    private var appVersion: Version {
        guard let versionString = retrieveFromInfoDictionary(key: "CFBundleShortVersionString"),
              let version = Version(string: versionString) else {
            return .one
        }
        return version
    }
    
    private func retrieveFromInfoDictionary(key: String) -> String? {
        app.infoDictionary?[key] as? String
    }
    
    private var appInfo: String {
        "\(appName)/\(appVersion)"
    }
    
    // MARK: Creating the Device Version string
    private var osVersion: String {
        return "\(device.systemName)/\(device.systemVersion)"
    }
    
    // MARK: Creating the Network Version string
    private var cfNetwork: String {
        "CFNetwork/\(cfNetworkVersion)"
    }
    
    
    private var cfNetworkVersion: String {
        guard let dictionary = cfApp?.infoDictionary,
              let versionString = dictionary["CFBundleShortVersionString"] as? String else {
            return "Unknown"
        }
        return versionString
    }
    
    // MARK: Creating the UserAgent header string
    var description: String {
        "\(appInfo) \(deviceModel) \(osVersion) \(cfNetwork) \(darwin)"
    }
}
