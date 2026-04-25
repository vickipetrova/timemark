import SwiftUI
import SwiftData

struct CategoryPillsView: View {
    let categories: [EventCategory]
    let events: [TrackedEvent]
    @Binding var selectedCategoryID: UUID?

    var onEdit: (EventCategory) -> Void
    var onDelete: (EventCategory) -> Void

    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                pill(
                    id: nil,
                    name: "All",
                    systemImage: "square.grid.2x2",
                    count: events.count
                )

                ForEach(categories) { category in
                    pill(
                        id: category.id,
                        name: category.name,
                        systemImage: category.sfSymbol,
                        count: events.filter { $0.categoryID == category.id }.count
                    )
                    .contextMenu {
                        Button {
                            onEdit(category)
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        Button(role: .destructive) {
                            onDelete(category)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
        }
    }

    @ViewBuilder
    private func pill(
        id: UUID?,
        name: String,
        systemImage: String,
        count: Int
    ) -> some View {
        let isSelected = selectedCategoryID == id
        let muted = AppTheme.mutedForeground(for: colorScheme)

        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedCategoryID = id
            }
            HapticManager.selection()
        } label: {
            HStack(spacing: 5) {
                Image(systemName: systemImage)
                    .font(.system(size: 10, weight: .thin))
                Text(name.uppercased())
                    .font(.caption2.weight(.medium))
                    .tracking(1.5)
                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 8, weight: .regular, design: .monospaced))
                        .baselineOffset(4)
                }
            }
            .foregroundStyle(isSelected ? theme.accentColor : muted)
            .padding(.horizontal, 10)
            .frame(height: 28)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(isSelected ? theme.accentColor.opacity(0.1) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(isSelected ? theme.accentColor : muted.opacity(0.5), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
