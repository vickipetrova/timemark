import SwiftUI

struct OnboardingConceptPage: View {
    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    let navigate: (OnboardingScreen) -> Void

    var body: some View {
        VStack(spacing: 0) {
            OnboardingProgressBar(progress: 1 / 3)
                .padding(.top, 16)

            ScrollView {
                VStack(alignment: .leading, spacing: 40) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("HOW IT WORKS")
                            .font(.caption2)
                            .tracking(3)
                            .foregroundStyle(AppTheme.mutedForeground(for: colorScheme))

                        Text("Track time in two directions")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(AppTheme.foreground(for: colorScheme))
                    }
                    .padding(.top, 32)

                    conceptCard(
                        label: "TIME SINCE",
                        example: "Quit smoking",
                        value: "142",
                        unit: "DAYS AGO",
                        description: "Count up from a past event. See how far you've come."
                    )

                    conceptCard(
                        label: "TIME UNTIL",
                        example: "Wedding day",
                        value: "58",
                        unit: "DAYS LEFT",
                        description: "Count down to a future date. Stay aware of what's ahead."
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }

            Spacer()

            Button(action: { navigate(.features) }) {
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
    private func conceptCard(
        label: String,
        example: String,
        value: String,
        unit: String,
        description: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(label)
                .font(.caption2)
                .tracking(3)
                .foregroundStyle(theme.accentColor(for: colorScheme))

            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(example)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(AppTheme.foreground(for: colorScheme))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(value)
                        .font(.system(size: 36, weight: .ultraLight, design: .monospaced))
                        .foregroundStyle(AppTheme.foreground(for: colorScheme))
                    Text(unit)
                        .font(.caption2)
                        .tracking(2)
                        .foregroundStyle(AppTheme.mutedForeground(for: colorScheme))
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(theme.mutedColor(for: colorScheme), lineWidth: 1)
            )

            Text(description)
                .font(.subheadline)
                .foregroundStyle(AppTheme.mutedForeground(for: colorScheme))
        }
    }
}

#Preview {
    OnboardingConceptPage(navigate: { _ in })
}
