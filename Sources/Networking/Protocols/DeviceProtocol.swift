import UIKit

/// Device
///
/// Extends `Bundle` to provide an abstraction layer to decouple required properties for use in ``UserAgent`` struct and in mocks.
protocol Device {
    var systemName: String { get }
    var systemVersion: String { get }
}

extension UIDevice: Device { }
