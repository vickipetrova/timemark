import SwiftUI
import SwiftData

struct MainView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
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
    }
}

#Preview {
    MainView()
        .modelContainer(for: [TrackedEvent.self, EventCategory.self], inMemory: true)
}
