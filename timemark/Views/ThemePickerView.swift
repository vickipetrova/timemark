import SwiftUI

struct ThemePickerView: View {
    @AppStorage("selectedTheme") private var selectedThemeRaw: String = AppTheme.monochrome.rawValue
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 12) {
            ForEach(AppTheme.allCases) { theme in
                Button {
                    selectedThemeRaw = theme.rawValue
                    HapticManager.light()
                } label: {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(theme.accentColor)
                        .frame(width: 12, height: 12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 2)
                                .stroke(AppTheme.foreground(for: colorScheme).opacity(0.3), lineWidth: 1)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(
                                    selectedThemeRaw == theme.rawValue
                                        ? theme.accentColor
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
