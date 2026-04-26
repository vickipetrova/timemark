import SwiftUI

enum LayoutTier {
    case compact
    case regular
    case expansive

    init(horizontal: UserInterfaceSizeClass?, screenWidth: CGFloat) {
        if horizontal == .compact {
            self = .compact
        } else if screenWidth >= 1100 {
            self = .expansive
        } else {
            self = .regular
        }
    }
}

private struct LayoutTierKey: EnvironmentKey {
    static let defaultValue: LayoutTier = .compact
}

extension EnvironmentValues {
    var layoutTier: LayoutTier {
        get { self[LayoutTierKey.self] }
        set { self[LayoutTierKey.self] = newValue }
    }
}
