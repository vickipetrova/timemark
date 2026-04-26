import SwiftUI
import SwiftData

struct SidebarView: View {
    @Binding var selectedCategoryID: UUID?

    @Environment(\.modelContext) private var modelContext
    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    @Query(sort: \EventCategory.sortOrder) private var categories: [EventCategory]
    @Query private var allEvents: [TrackedEvent]

    @State private var editingCategory: EventCategory?
    @State private var showingCreateCategory = false
    @State private var categoryToDelete: EventCategory?

    var body: some View {
        List(selection: $selectedCategoryID) {
            allEventsRow
                .tag(nil as UUID?)

            Section {
                ForEach(categories) { category in
                    categoryRow(category)
                        .tag(category.id as UUID?)
                        .contextMenu {
                            Button {
                                editingCategory = category
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            Button(role: .destructive) {
                                categoryToDelete = category
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
                .onMove(perform: reorderCategories)
            } header: {
                Text("CATEGORIES")
                    .font(.caption2)
                    .tracking(3)
                    .foregroundStyle(AppTheme.mutedForeground(for: colorScheme))
            }

            Section {
                Button {
                    showingCreateCategory = true
                    HapticManager.light()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .thin))
                        Text("CATEGORY")
                            .font(.caption.weight(.medium))
                            .tracking(2)
                    }
                    .foregroundStyle(theme.accentColor(for: colorScheme))
                }
                .buttonStyle(.plain)
            }
        }
        .listStyle(.sidebar)
        .scrollContentBackground(.hidden)
        .background(AppTheme.background(for: colorScheme))
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Text("TALLY DAYS")
                    .font(.caption.weight(.medium))
                    .tracking(4)
                    .foregroundStyle(AppTheme.foreground(for: colorScheme))
            }
        }
        .sheet(isPresented: $showingCreateCategory) {
            CreateCategoryView(mode: .create)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(item: $editingCategory) { category in
            CreateCategoryView(mode: .edit(category))
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .confirmationDialog(
            categoryToDelete.map { "Delete '\($0.name)'?" } ?? "",
            isPresented: Binding(
                get: { categoryToDelete != nil },
                set: { if !$0 { categoryToDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let category = categoryToDelete {
                    deleteCategoryAndClearEvents(category)
                }
                categoryToDelete = nil
            }
            Button("Cancel", role: .cancel) { categoryToDelete = nil }
        }
    }

    private var allEventsRow: some View {
        HStack {
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 14, weight: .thin))
                .foregroundStyle(theme.accentColor(for: colorScheme))
            Text("ALL EVENTS")
                .font(.caption.weight(.medium))
                .tracking(1.5)
                .foregroundStyle(AppTheme.foreground(for: colorScheme))
            Spacer()
            Text("\(allEvents.count)")
                .font(.system(size: 12, weight: .regular, design: .monospaced))
                .foregroundStyle(AppTheme.mutedForeground(for: colorScheme))
        }
        .contentShape(Rectangle())
    }

    private func categoryRow(_ category: EventCategory) -> some View {
        let count = allEvents.filter { $0.categoryID == category.id }.count
        return HStack {
            Image(systemName: category.sfSymbol)
                .font(.system(size: 14, weight: .thin))
                .foregroundStyle(category.color)
            Text(category.name)
                .font(.body)
                .foregroundStyle(AppTheme.foreground(for: colorScheme))
            Spacer()
            Text("\(count)")
                .font(.system(size: 12, weight: .regular, design: .monospaced))
                .foregroundStyle(AppTheme.mutedForeground(for: colorScheme))
        }
        .contentShape(Rectangle())
    }

    private func reorderCategories(from source: IndexSet, to destination: Int) {
        var ordered = categories
        ordered.move(fromOffsets: source, toOffset: destination)
        for (index, category) in ordered.enumerated() {
            category.sortOrder = index
        }
        try? modelContext.save()
        HapticManager.light()
    }

    private func deleteCategoryAndClearEvents(_ category: EventCategory) {
        for event in allEvents where event.categoryID == category.id {
            event.categoryID = nil
        }
        modelContext.delete(category)
        try? modelContext.save()
        if selectedCategoryID == category.id {
            selectedCategoryID = nil
        }
        HapticManager.medium()
    }
}
