import Foundation

/// AppBundle
///
/// Extends `Bundle` to provide an abstraction layer to decouple required properties for use in ``UserAgent`` struct and in mocks.
protocol AppBundle {
    var infoDictionary: [String: Any]? { get }
}

extension Bundle: AppBundle { }
