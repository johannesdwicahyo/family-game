import SwiftUI

/// Type: Bricolage Grotesque ExtraBold for display (a characterful, grown-up grotesk),
/// SF Pro for everything else.
enum HuddleFont {
    static let displayName = "BricolageGrotesque-36ptExtraBold"

    static func display(_ size: CGFloat = 36) -> Font {
        .custom(displayName, size: size)
    }
    static func heading(_ size: CGFloat = 22) -> Font {
        .system(size: size, weight: .bold)
    }
    static func body(_ size: CGFloat = 16) -> Font {
        .system(size: size, weight: .regular)
    }
    static func caption(_ size: CGFloat = 12) -> Font {
        .system(size: size, weight: .semibold)
    }
}
