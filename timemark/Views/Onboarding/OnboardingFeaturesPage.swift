import SwiftUI

struct OnboardingFeaturesPage: View {
    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    let navigate: (OnboardingScreen) -> Void

    private let features: [(symbol: String, title: String, subtitle: String)] = [
        ("arrow.up.arrow.down", "SINCE & UNTIL", "Count up from the past or down to the future"),
        ("square.stack", "CATEGORIES", "Organize events by life, work, health, or your own"),
        ("bell", "REMINDERS", "Daily, weekly, or monthly nudges so you never lose track"),
        ("widget.small", "WIDGETS", "Glance at your counts from the home or lock screen"),
        ("paintpalette", "THEMES", "Five muted palettes that adapt to light and dark"),
        ("square.and.arrow.up", "SHARING", "Send events to friends with a single tap"),
        ("icloud", "CLOUD SYNC", "Your data stays in sync across all your devices"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            OnboardingProgressBar(progress: 2 / 3)
                .padding(.top, 16)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("FEATURES")
                            .font(.caption2)
                            .tracking(3)
                            .foregroundStyle(AppTheme.mutedForeground(for: colorScheme))

                        Text("Everything you need, nothing you don't")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(AppTheme.foreground(for: colorScheme))
                    }
                    .padding(.top, 32)

                    VStack(spacing: 8) {
                        ForEach(features, id: \.title) { feature in
                            featureRow(
                                symbol: feature.symbol,
                                title: feature.title,
                                subtitle: feature.subtitle
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }

            Spacer()

            Button(action: { navigate(.final_) }) {
                Text("CONTINUE")
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

    @ViewBuilder
    private func featureRow(symbol: String, title: String, subtitle: String) -> some View {
        HStack(alignment: .center, spacing: 16) {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .light))
                .foregroundStyle(theme.accentColor(for: colorScheme))
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2.weight(.medium))
                    .tracking(1.5)
                    .foregroundStyle(AppTheme.foreground(for: colorScheme))

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(AppTheme.mutedForeground(for: colorScheme))
            }

            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(theme.mutedColor(for: colorScheme).opacity(0.5), lineWidth: 1)
        )
    }
}

#Preview {
    OnboardingFeaturesPage(navigate: { _ in })
}
