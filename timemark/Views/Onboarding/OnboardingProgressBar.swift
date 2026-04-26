import SwiftUI

struct OnboardingProgressBar: View {
    var progress: CGFloat
    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(theme.mutedColor(for: colorScheme).opacity(0.3))
                    .frame(height: 2)

                RoundedRectangle(cornerRadius: 2)
                    .fill(theme.accentColor(for: colorScheme))
                    .frame(width: geometry.size.width * progress, height: 2)
                    .animation(.easeInOut(duration: 0.25), value: progress)
            }
        }
        .frame(height: 2)
        .padding(.horizontal, 20)
    }
}
