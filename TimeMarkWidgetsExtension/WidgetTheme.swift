import SwiftUI

struct WidgetTheme {
    let accent: Color
    let muted: Color

    static var current: WidgetTheme {
        let defaults = SharedModelContainer.sharedDefaults
        let raw = defaults?.string(forKey: "selectedTheme") ?? "monochrome"
        switch raw {
        case "slate":
            return WidgetTheme(accent: Color(hex: "#5A7A8A"), muted: Color(hex: "#5A7A8A").opacity(0.5))
        case "forest":
            return WidgetTheme(accent: Color(hex: "#4A6B4F"), muted: Color(hex: "#4A6B4F").opacity(0.5))
        case "oxide":
            return WidgetTheme(accent: Color(hex: "#7A5C42"), muted: Color(hex: "#7A5C42").opacity(0.5))
        case "steel":
            return WidgetTheme(accent: Color(hex: "#556B7A"), muted: Color(hex: "#556B7A").opacity(0.5))
        default:
            return WidgetTheme(accent: Color(hex: "#6B6B6B"), muted: Color(hex: "#6B6B6B").opacity(0.5))
        }
    }
}
