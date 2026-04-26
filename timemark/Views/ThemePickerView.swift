import SwiftUI
import WidgetKit

struct ThemePickerView: View {
    @AppStorage("selectedTheme", store: UserDefaults(suiteName: SharedModelContainer.appGroupID))
    private var selectedThemeRaw: String = AppTheme.monochrome.rawValue
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 12) {
            ForEach(AppTheme.allCases) { theme in
                Button {
                    selectedThemeRaw = theme.rawValue
                    WidgetCenter.shared.reloadAllTimelines()
                    HapticManager.light()
                } label: {
                    Group {
                        if theme.isSpectrum {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "#E74C3C"), Color(hex: "#F39C12"), Color(hex: "#27AE60"), Color(hex: "#3498DB")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 12, height: 12)
                        } else {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(theme.accentColor(for: colorScheme))
                                .frame(width: 12, height: 12)
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(AppTheme.foreground(for: colorScheme).opacity(0.3), lineWidth: 1)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(
                                selectedThemeRaw == theme.rawValue
                                    ? (theme.isSpectrum ? Color(hex: "#3498DB") : theme.accentColor(for: colorScheme))
                                    : Color.clear,
                                lineWidth: 1
                            )
                            .frame(width: 18, height: 18)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(AppTheme.background(for: colorScheme))
    }
}

#Preview {
    ThemePickerView()
}
