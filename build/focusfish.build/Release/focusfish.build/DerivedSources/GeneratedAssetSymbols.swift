import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

    /// The "AppLogo" asset catalog image resource.
    static let appLogo = DeveloperToolsSupport.ImageResource(name: "AppLogo", bundle: resourceBundle)

    /// The "blazetail" asset catalog image resource.
    static let blazetail = DeveloperToolsSupport.ImageResource(name: "blazetail", bundle: resourceBundle)

    /// The "bubbly" asset catalog image resource.
    static let bubbly = DeveloperToolsSupport.ImageResource(name: "bubbly", bundle: resourceBundle)

    /// The "cat" asset catalog image resource.
    static let cat = DeveloperToolsSupport.ImageResource(name: "cat", bundle: resourceBundle)

    /// The "dog" asset catalog image resource.
    static let dog = DeveloperToolsSupport.ImageResource(name: "dog", bundle: resourceBundle)

    /// The "focus" asset catalog image resource.
    static let focus = DeveloperToolsSupport.ImageResource(name: "focus", bundle: resourceBundle)

    /// The "glint" asset catalog image resource.
    static let glint = DeveloperToolsSupport.ImageResource(name: "glint", bundle: resourceBundle)

    /// The "minno" asset catalog image resource.
    static let minno = DeveloperToolsSupport.ImageResource(name: "minno", bundle: resourceBundle)

    /// The "moonshark" asset catalog image resource.
    static let moonshark = DeveloperToolsSupport.ImageResource(name: "moonshark", bundle: resourceBundle)

    /// The "shadowfin" asset catalog image resource.
    static let shadowfin = DeveloperToolsSupport.ImageResource(name: "shadowfin", bundle: resourceBundle)

    /// The "speck" asset catalog image resource.
    static let speck = DeveloperToolsSupport.ImageResource(name: "speck", bundle: resourceBundle)

    /// The "stripes" asset catalog image resource.
    static let stripes = DeveloperToolsSupport.ImageResource(name: "stripes", bundle: resourceBundle)

    /// The "swoop" asset catalog image resource.
    static let swoop = DeveloperToolsSupport.ImageResource(name: "swoop", bundle: resourceBundle)

}

// MARK: - Color Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

}
#endif

// MARK: - Image Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    /// The "AppLogo" asset catalog image.
    static var appLogo: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .appLogo)
#else
        .init()
#endif
    }

    /// The "blazetail" asset catalog image.
    static var blazetail: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .blazetail)
#else
        .init()
#endif
    }

    /// The "bubbly" asset catalog image.
    static var bubbly: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bubbly)
#else
        .init()
#endif
    }

    /// The "cat" asset catalog image.
    static var cat: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .cat)
#else
        .init()
#endif
    }

    /// The "dog" asset catalog image.
    static var dog: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .dog)
#else
        .init()
#endif
    }

    /// The "focus" asset catalog image.
    static var focus: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .focus)
#else
        .init()
#endif
    }

    /// The "glint" asset catalog image.
    static var glint: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .glint)
#else
        .init()
#endif
    }

    /// The "minno" asset catalog image.
    static var minno: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .minno)
#else
        .init()
#endif
    }

    /// The "moonshark" asset catalog image.
    static var moonshark: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .moonshark)
#else
        .init()
#endif
    }

    /// The "shadowfin" asset catalog image.
    static var shadowfin: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .shadowfin)
#else
        .init()
#endif
    }

    /// The "speck" asset catalog image.
    static var speck: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .speck)
#else
        .init()
#endif
    }

    /// The "stripes" asset catalog image.
    static var stripes: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .stripes)
#else
        .init()
#endif
    }

    /// The "swoop" asset catalog image.
    static var swoop: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .swoop)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// The "AppLogo" asset catalog image.
    static var appLogo: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .appLogo)
#else
        .init()
#endif
    }

    /// The "blazetail" asset catalog image.
    static var blazetail: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .blazetail)
#else
        .init()
#endif
    }

    /// The "bubbly" asset catalog image.
    static var bubbly: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .bubbly)
#else
        .init()
#endif
    }

    /// The "cat" asset catalog image.
    static var cat: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .cat)
#else
        .init()
#endif
    }

    /// The "dog" asset catalog image.
    static var dog: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .dog)
#else
        .init()
#endif
    }

    /// The "focus" asset catalog image.
    static var focus: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .focus)
#else
        .init()
#endif
    }

    /// The "glint" asset catalog image.
    static var glint: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .glint)
#else
        .init()
#endif
    }

    /// The "minno" asset catalog image.
    static var minno: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .minno)
#else
        .init()
#endif
    }

    /// The "moonshark" asset catalog image.
    static var moonshark: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .moonshark)
#else
        .init()
#endif
    }

    /// The "shadowfin" asset catalog image.
    static var shadowfin: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .shadowfin)
#else
        .init()
#endif
    }

    /// The "speck" asset catalog image.
    static var speck: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .speck)
#else
        .init()
#endif
    }

    /// The "stripes" asset catalog image.
    static var stripes: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .stripes)
#else
        .init()
#endif
    }

    /// The "swoop" asset catalog image.
    static var swoop: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .swoop)
#else
        .init()
#endif
    }

}
#endif

// MARK: - Thinnable Asset Support -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ColorResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if AppKit.NSColor(named: NSColor.Name(thinnableName), bundle: bundle) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIColor(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}
#endif

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ImageResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if bundle.image(forResource: NSImage.Name(thinnableName)) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

