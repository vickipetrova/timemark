import SwiftUI

struct OnboardingFinalPage: View {
    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            OnboardingProgressBar(progress: 1.0)
                .padding(.top, 16)

            Spacer()

            VStack(spacing: 24) {
                Text("0")
                    .font(.system(size: 72, weight: .ultraLight, design: .monospaced))
                    .foregroundStyle(theme.accentColor(for: colorScheme))

                VStack(spacing: 8) {
                    Text("YOU'RE ALL SET")
                        .font(.caption.weight(.medium))
                        .tracking(4)
                        .foregroundStyle(AppTheme.foreground(for: colorScheme))

                    Text("Start by creating your first event.\nTap + to begin tracking what matters.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AppTheme.mutedForeground(for: colorScheme))
                        .lineSpacing(4)
                }
            }

            Spacer()

            Button(action: finish) {
                Text("LET'S GO")
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

    private func finish() {
        HapticManager.light()
        hasSeenOnboarding = true
    }
}

#Preview {
    OnboardingFinalPage()
}
