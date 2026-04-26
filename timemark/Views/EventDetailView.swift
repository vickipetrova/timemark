import SwiftUI
import SwiftData
import WidgetKit

struct EventDetailView: View {
    @Bindable var event: TrackedEvent
    var isInDetailColumn: Bool = false

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Query(sort: \EventCategory.sortOrder) private var categories: [EventCategory]

    @State private var showingEdit = false
    @State private var showingDelete = false
    @State private var showingShare = false

    var body: some View {
        let formatted = TimeFormatter.format(
            from: event.eventDate,
            type: event.eventType,
            format: event.displayFormat
        )

        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                header

                VStack(spacing: 8) {
                    Text(formatted.value)
                        .font(.system(size: isInDetailColumn ? 96 : 72, weight: .ultraLight, design: .monospaced))
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .foregroundStyle(AppTheme.foreground(for: colorScheme))

                    if !formatted.unit.isEmpty {
                        Text(formatted.unit.uppercased())
                            .font(.title3)
                            .tracking(6)
                            .foregroundStyle(AppTheme.mutedForeground(for: colorScheme))
                    }

                    Text(subheading)
                        .font(.caption)
                        .foregroundStyle(AppTheme.mutedForeground(for: colorScheme))
                        .padding(.top, 4)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)

                Rectangle()
                    .fill(theme.mutedColor(for: colorScheme))
                    .frame(height: 1)

                actions

                historySection
            }
            .padding(20)
        }
        .background(AppTheme.background(for: colorScheme))
        .foregroundStyle(AppTheme.foreground(for: colorScheme))
        .navigationTitle(isInDetailColumn ? "" : event.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isInDetailColumn {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingEdit = true
                    } label: {
                        Text("EDIT")
                            .font(.caption.weight(.medium))
                            .tracking(2)
                            .foregroundStyle(AppTheme.foreground(for: colorScheme))
                    }
                    .keyboardShortcut("e", modifiers: .command)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingShare = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .fontWeight(.thin)
                            .foregroundStyle(AppTheme.foreground(for: colorScheme))
                    }
                }
            } else {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button { showingEdit = true } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        Button { showingShare = true } label: {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        Button(role: .destructive) {
                            showingDelete = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .fontWeight(.thin)
                            .foregroundStyle(AppTheme.foreground(for: colorScheme))
                    }
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            CreateEventView(mode: .edit(event))
                .presentationDetents(isInDetailColumn ? [.medium, .large] : [.large])
                .presentationDragIndicator(isInDetailColumn ? .visible : .hidden)
        }
        .sheet(isPresented: $showingShare) {
            ShareSheet(activityItems: shareItems)
                .presentationDetents([.medium])
        }
        .confirmationDialog(
            "Delete '\(event.title)'?",
            isPresented: $showingDelete,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive, action: performDelete)
            Button("Cancel", role: .cancel) {}
        }
    }

    private var detailAccent: Color {
        if theme.isSpectrum, let category = resolvedCategory {
            return category.color
        }
        return theme.accentColor(for: colorScheme)
    }

    private var header: some View {
        HStack(spacing: 8) {
            if let category = resolvedCategory {
                let badgeColor = theme.isSpectrum ? category.color : theme.accentColor(for: colorScheme)
                HStack(spacing: 5) {
                    Image(systemName: category.sfSymbol)
                        .font(.system(size: 10, weight: .thin))
                    Text(category.name.uppercased())
                        .font(.caption2.weight(.medium))
                        .tracking(1.5)
                }
                .foregroundStyle(badgeColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(badgeColor, lineWidth: 1)
                )
            }
            Text(event.eventType.short.uppercased())
                .font(.caption2.weight(.medium))
                .tracking(1.5)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(theme.mutedColor(for: colorScheme), lineWidth: 1)
                )
                .foregroundStyle(AppTheme.mutedForeground(for: colorScheme))
        }
    }

    private var actions: some View {
        HStack(spacing: 10) {
            outlineButton("LOG NOW") {
                logNow()
            }
            outlineButton("EDIT") {
                showingEdit = true
            }
            outlineButton("SHARE") {
                showingShare = true
            }
        }
    }

    @ViewBuilder
    private func outlineButton(_ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.caption.weight(.medium))
                .tracking(2)
                .foregroundStyle(detailAccent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(detailAccent, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("HISTORY")
                .font(.caption2)
                .tracking(3)
                .foregroundStyle(AppTheme.mutedForeground(for: colorScheme))
                .padding(.bottom, 12)

            if event.dateHistory.isEmpty {
                Text("No previous entries.")
                    .font(.caption)
                    .foregroundStyle(AppTheme.mutedForeground(for: colorScheme))
                    .padding(.vertical, 8)
            } else {
                ForEach(Array(event.dateHistory.enumerated().reversed()), id: \.offset) { index, date in
                    VStack(spacing: 0) {
                        HStack {
                            Text(date.mediumFormatted)
                                .font(.caption)
                                .foregroundStyle(AppTheme.foreground(for: colorScheme))
                            Spacer()
                            Text(date.relativeDescription)
                                .font(.caption)
                                .foregroundStyle(AppTheme.mutedForeground(for: colorScheme))
                            Button {
                                deleteHistory(at: index)
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 8, weight: .thin))
                                    .foregroundStyle(AppTheme.mutedForeground(for: colorScheme))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, 10)

                        Rectangle()
                            .fill(theme.mutedColor(for: colorScheme).opacity(0.5))
                            .frame(height: 0.5)
                    }
                }
            }
        }
    }

    private var resolvedCategory: EventCategory? {
        guard let id = event.categoryID else { return nil }
        return categories.first(where: { $0.id == id })
    }

    private var subheading: String {
        switch event.eventType {
        case .since:
            return "Started on \(event.eventDate.longFormatted)"
        case .until:
            return "Counting down to \(event.eventDate.longFormatted)"
        }
    }

    private var shareItems: [Any] {
        var items: [Any] = [ShareManager.makeShareMessage(for: event)]
        if let url = ShareManager.makeShareURL(for: event) {
            items.append(url)
        }
        return items
    }

    private func logNow() {
        event.dateHistory.append(event.eventDate)
        if event.eventType == .since {
            event.eventDate = Date()
        }
        try? modelContext.save()
        WidgetCenter.shared.reloadAllTimelines()
        HapticManager.medium()
    }

    private func deleteHistory(at index: Int) {
        guard event.dateHistory.indices.contains(index) else { return }
        event.dateHistory.remove(at: index)
        try? modelContext.save()
        HapticManager.light()
    }

    private func performDelete() {
        ReminderManager.shared.cancelReminder(for: event)
        modelContext.delete(event)
        try? modelContext.save()
        WidgetCenter.shared.reloadAllTimelines()
        HapticManager.medium()
        dismiss()
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
