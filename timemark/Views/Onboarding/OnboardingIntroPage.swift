import SwiftUI

struct OnboardingIntroPage: View {
    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    let navigate: (OnboardingScreen) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 16) {
                Text("0")
                    .font(.system(size: 120, weight: .ultraLight, design: .monospaced))
                    .foregroundStyle(theme.accentColor(for: colorScheme))

                Text("TALLYDAYS")
                    .font(.caption.weight(.medium))
                    .tracking(6)
                    .foregroundStyle(AppTheme.foreground(for: colorScheme))

                Text("Count the days that matter.")
                    .font(.body)
                    .foregroundStyle(AppTheme.mutedForeground(for: colorScheme))
                    .padding(.top, 4)
            }

            Spacer()

            Button(action: { navigate(.concept) }) {
                Text("GET STARTED")
                    .font(.caption.weight(.medium))
                    .tracking(2)
                    .foregroundStyle(theme.accentColor(for: colorScheme))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(theme.accentColor(for: colorScheme), lineWidth: 1)
                    )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(AppTheme.background(for: colorScheme))
    }
}

#Preview {
    OnboardingIntroPage(navigate: { _ in })
}
