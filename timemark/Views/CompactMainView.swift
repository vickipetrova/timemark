import SwiftUI
import SwiftData
import WidgetKit

struct CompactMainView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    @Query private var allEvents: [TrackedEvent]
    @Query(sort: \EventCategory.sortOrder) private var categories: [EventCategory]

    @AppStorage("sortOrder") private var sortOrderRaw: String = EventSortOrder.dateCreated.rawValue

    @State private var viewModel = EventsViewModel()
    @State private var selectedCategoryID: UUID?
    @State private var showingCreateEvent = false
    @State private var showingCreateCategory = false
    @State private var editingCategory: EventCategory?
    @State private var showingThemePicker = false
    @State private var categoryToDelete: EventCategory?
    @State private var incomingSharedPayload: SharedEventPayload?
    @State private var showingSharedConfirm = false

    private var sortOrder: EventSortOrder {
        EventSortOrder(rawValue: sortOrderRaw) ?? .dateCreated
    }

    private var filteredEvents: [TrackedEvent] {
        let filtered = viewModel.filter(allEvents, categoryID: selectedCategoryID)
        return viewModel.sort(filtered, by: sortOrder)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                toolbarDivider

                CategoryPillsView(
                    categories: categories,
                    events: allEvents,
                    selectedCategoryID: $selectedCategoryID,
                    onEdit: { category in editingCategory = category },
                    onDelete: { category in categoryToDelete = category }
                )
                .padding(.top, 8)
                .padding(.bottom, 8)

                eventList

                bottomBar
            }
            .background(AppTheme.background(for: colorScheme))
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .sheet(isPresented: $showingCreateEvent) {
                CreateEventView(mode: .create)
            }
            .sheet(isPresented: $showingCreateCategory) {
                CreateCategoryView(mode: .create)
            }
            .sheet(item: $editingCategory) { category in
                CreateCategoryView(mode: .edit(category))
            }
            .sheet(isPresented: $showingSharedConfirm) {
                if let payload = incomingSharedPayload {
                    CreateEventView(mode: .create, prefilled: payload)
                }
            }
            .navigationDestination(for: TrackedEvent.self) { event in
                EventDetailView(event: event)
            }
            .navigationDestination(for: EventCategory.self) { category in
                CategoryEventsView(category: category)
            }
            .onOpenURL { url in
                handleIncomingURL(url)
            }
            .onReceive(NotificationCenter.default.publisher(for: .createEvent)) { _ in
                showingCreateEvent = true
            }
            .onReceive(NotificationCenter.default.publisher(for: .createCategory)) { _ in
                showingCreateCategory = true
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
                        viewModel.delete(category, events: allEvents, context: modelContext)
                        try? modelContext.save()
                        HapticManager.medium()
                    }
                    categoryToDelete = nil
                }
                Button("Cancel", role: .cancel) { categoryToDelete = nil }
            }
        }
    }

    private var toolbarDivider: some View {
        Rectangle()
            .fill(theme.mutedColor(for: colorScheme))
            .frame(height: 1)
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            NavigationLink {
                SettingsView()
            } label: {
                Image(systemName: "gearshape")
                    .fontWeight(.thin)
                    .foregroundStyle(AppTheme.foreground(for: colorScheme))
            }
        }

        ToolbarItem(placement: .topBarLeading) {
            Menu {
                Picker("Sort", selection: $sortOrderRaw) {
                    ForEach(EventSortOrder.allCases) { order in
                        Label(order.label, systemImage: order.systemImage)
                            .tag(order.rawValue)
                    }
                }
            } label: {
                Image(systemName: "arrow.up.arrow.down")
                    .fontWeight(.thin)
                    .foregroundStyle(AppTheme.foreground(for: colorScheme))
            }
        }

        ToolbarItem(placement: .principal) {
            Text("TALLY DAYS")
                .font(.caption.weight(.medium))
                .tracking(4)
                .foregroundStyle(AppTheme.foreground(for: colorScheme))
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showingThemePicker = true
            } label: {
                Image(systemName: "square")
                    .fontWeight(.thin)
                    .foregroundStyle(AppTheme.foreground(for: colorScheme))
            }
            .popover(isPresented: $showingThemePicker, arrowEdge: .top) {
                ThemePickerView()
                    .presentationCompactAdaptation(.popover)
            }
        }
    }

    private var eventList: some View {
        Group {
            if filteredEvents.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        if sortOrder == .manual {
                            ForEach(filteredEvents) { event in
                                eventRow(for: event)
                                    .draggable(event.id.uuidString) {
                                        EventCardView(event: event, category: category(for: event))
                                            .frame(width: 300)
                                    }
                                    .dropDestination(for: String.self) { items, _ in
                                        return handleDrop(items: items, target: event)
                                    }
                            }
                        } else {
                            ForEach(filteredEvents) { event in
                                eventRow(for: event)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                }
                .scrollDismissesKeyboard(.immediately)
                .refreshable {
                    try? await Task.sleep(nanoseconds: 400_000_000)
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: selectedCategoryID)
    }

    private func eventRow(for event: TrackedEvent) -> some View {
        NavigationLink(value: event) {
            EventCardView(event: event, category: category(for: event))
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                viewModel.resetEvent(event)
                try? modelContext.save()
                HapticManager.medium()
            } label: {
                Label("Log Now", systemImage: "arrow.counterclockwise")
            }
            NavigationLink(value: event) {
                Label("Details", systemImage: "info.circle")
            }
            Button(role: .destructive) {
                viewModel.delete(event, context: modelContext)
                try? modelContext.save()
                HapticManager.medium()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                viewModel.delete(event, context: modelContext)
                try? modelContext.save()
            } label: {
                Text("DELETE")
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button {
                viewModel.resetEvent(event)
                try? modelContext.save()
                HapticManager.medium()
            } label: {
                Text("RESET")
            }
            .tint(theme.accentColor(for: colorScheme))
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Text("NO EVENTS YET")
                .font(.caption)
                .tracking(4)
                .foregroundStyle(AppTheme.mutedForeground(for: colorScheme))
            Text("Tap + Event to begin tracking")
                .font(.caption2)
                .foregroundStyle(AppTheme.mutedForeground(for: colorScheme).opacity(0.6))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var bottomBar: some View {
        let accent = theme.accentColor(for: colorScheme)
        return VStack(spacing: 0) {
            Rectangle()
                .fill(theme.mutedColor(for: colorScheme))
                .frame(height: 1)

            HStack(spacing: 12) {
                Button {
                    showingCreateEvent = true
                    HapticManager.light()
                } label: {
                    Text("+ EVENT")
                        .font(.caption.weight(.medium))
                        .tracking(2)
                        .foregroundStyle(accent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(accent, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)

                Button {
                    showingCreateCategory = true
                    HapticManager.light()
                } label: {
                    Text("+ CATEGORY")
                        .font(.caption.weight(.medium))
                        .tracking(2)
                        .foregroundStyle(accent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(accent, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 14)
            .background(AppTheme.background(for: colorScheme))
        }
    }

    private func category(for event: TrackedEvent) -> EventCategory? {
        guard let id = event.categoryID else { return nil }
        return categories.first(where: { $0.id == id })
    }

    private func handleDrop(items: [String], target: TrackedEvent) -> Bool {
        guard let draggedIDString = items.first,
              let draggedUUID = UUID(uuidString: draggedIDString),
              let dragged = allEvents.first(where: { $0.id == draggedUUID }),
              dragged.id != target.id else {
            return false
        }

        var ordered = viewModel.sort(allEvents, by: .manual)
        if let fromIndex = ordered.firstIndex(where: { $0.id == dragged.id }),
           let toIndex = ordered.firstIndex(where: { $0.id == target.id }) {
            ordered.remove(at: fromIndex)
            let insertIndex = fromIndex < toIndex ? toIndex : toIndex
            ordered.insert(dragged, at: min(insertIndex, ordered.count))
            for (index, event) in ordered.enumerated() {
                event.sortOrder = index
            }
            try? modelContext.save()
            WidgetCenter.shared.reloadAllTimelines()
            HapticManager.light()
            return true
        }
        return false
    }

    private func handleIncomingURL(_ url: URL) {
        guard let payload = ShareManager.decode(url: url) else { return }
        incomingSharedPayload = payload
        showingSharedConfirm = true
    }
}
