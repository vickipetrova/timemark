import SwiftUI

struct EmptyDetailPlaceholder: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Text("SELECT AN EVENT")
            .font(.caption)
            .tracking(4)
            .foregroundStyle(AppTheme.mutedForeground(for: colorScheme))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.background(for: colorScheme))
    }
}
