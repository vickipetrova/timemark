import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable, Codable {
    case monochrome
    case slate
    case forest
    case oxide
    case steel

    var id: String { rawValue }

    var label: String {
        switch self {
        case .monochrome: return "Monochrome"
        case .slate: return "Slate"
        case .forest: return "Forest"
        case .oxide: return "Oxide"
        case .steel: return "Steel"
        }
    }

    var accentColor: Color {
        switch self {
        case .monochrome: return Color(hex: "#6B6B6B")
        case .slate: return Color(hex: "#5A7A8A")
        case .forest: return Color(hex: "#4A6B4F")
        case .oxide: return Color(hex: "#7A5C42")
        case .steel: return Color(hex: "#556B7A")
        }
    }

    var primaryColor: Color {
        switch self {
        case .monochrome: return Color.white
        case .slate: return Color(hex: "#8FA3B0")
        case .forest: return Color(hex: "#6B8F71")
        case .oxide: return Color(hex: "#A0785A")
        case .steel: return Color(hex: "#7A8B9A")
        }
    }

    var mutedColor: Color {
        accentColor.opacity(0.5)
    }

    var swatch: Color {
        accentColor
    }

    var accent: Color { accentColor }

    var primary: Color { accentColor }

    func onAccentText(for scheme: ColorScheme) -> Color {
        .white
    }

    static func background(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: "#0A0A0A") : Color(hex: "#FAFAFA")
    }

    static func foreground(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: "#E8E8E8") : Color(hex: "#1A1A1A")
    }

    static func mutedForeground(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: "#E8E8E8").opacity(0.45) : Color(hex: "#1A1A1A").opacity(0.45)
    }
}

private struct AppThemeKey: EnvironmentKey {
    static let defaultValue: AppTheme = .monochrome
}

extension EnvironmentValues {
    var appTheme: AppTheme {
        get { self[AppThemeKey.self] }
        set { self[AppThemeKey.self] = newValue }
    }
}
