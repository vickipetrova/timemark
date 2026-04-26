import SwiftUI
import SwiftData

struct MainView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false

    var body: some View {
        if hasSeenOnboarding {
            GeometryReader { geometry in
                let tier = LayoutTier(horizontal: horizontalSizeClass, screenWidth: geometry.size.width)
                Group {
                    if tier == .compact {
                        CompactMainView()
                    } else {
                        SplitMainView()
                    }
                }
                .environment(\.layoutTier, tier)
            }
        } else {
            OnboardingRootView()
        }
    }
}

#Preview {
    MainView()
        .modelContainer(for: [TrackedEvent.self, EventCategory.self], inMemory: true)
}
