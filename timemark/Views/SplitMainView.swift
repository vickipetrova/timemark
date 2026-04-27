import SwiftUI
import SwiftData

struct SplitMainView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.layoutTier) private var layoutTier
    @Environment(ReviewManager.self) private var reviewManager

    @Query private var allEvents: [TrackedEvent]
    @Query(sort: \EventCategory.sortOrder) private var categories: [EventCategory]

    @AppStorage("sortOrder") private var sortOrderRaw: String = EventSortOrder.dateCreated.rawValue

    @State private var viewModel = EventsViewModel()
    @State private var selectedCategoryID: UUID?
    @State private var selectedEvent: TrackedEvent?
    @State private var showingCreateEvent = false
    @State private var showingCreateCategory = false
    @State private var showingThemePicker = false
    @State private var showingSettings = false
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
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
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SidebarView(selectedCategoryID: $selectedCategoryID)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                                .fontWeight(.thin)
                                .foregroundStyle(AppTheme.foreground(for: colorScheme))
                        }
                    }
                }
                .navigationSplitViewColumnWidth(min: 220, ideal: 260)
        } content: {
            contentColumn
                .navigationSplitViewColumnWidth(min: 300, ideal: 400)
        } detail: {
            if let event = selectedEvent {
                EventDetailView(event: event, isInDetailColumn: true)
            } else {
                EmptyDetailPlaceholder()
            }
        }
        .navigationSplitViewStyle(.balanced)
        .sheet(isPresented: $showingCreateEvent) {
            CreateEventView(mode: .create)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .frame(idealWidth: 500, idealHeight: 600)
        }
        .sheet(isPresented: $showingCreateCategory) {
            CreateCategoryView(mode: .create)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .frame(idealWidth: 500, idealHeight: 600)
        }
        .sheet(isPresented: $showingSettings) {
            NavigationStack {
                SettingsView()
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingSharedConfirm) {
            if let payload = incomingSharedPayload {
                CreateEventView(mode: .create, prefilled: payload)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
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
        .onReceive(NotificationCenter.default.publisher(for: .openSettings)) { _ in
            showingSettings = true
        }
    }

    private var contentColumn: some View {
        VStack(spacing: 0) {
            if filteredEvents.isEmpty {
                contentEmptyState
            } else {
                ScrollView {
                    let columns = gridColumns
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(filteredEvents) { event in
                            Button {
                                selectedEvent = event
                            } label: {
                                EventCardView(
                                    event: event,
                                    category: category(for: event),
                                    isSelected: selectedEvent?.id == event.id,
                                    useGridLayout: true
                                )
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button {
                                    viewModel.resetEvent(event)
                                    try? modelContext.save()
                                    HapticManager.medium()
                                    reviewManager.recordMeaningfulAction()
                                } label: {
                                    Label("Log Now", systemImage: "arrow.counterclockwise")
                                }
                                if !categories.isEmpty {
                                    Menu("Change Category") {
                                        Button("None") {
                                            event.categoryID = nil
                                            try? modelContext.save()
                                        }
                                        ForEach(categories) { cat in
                                            Button {
                                                event.categoryID = cat.id
                                                try? modelContext.save()
                                            } label: {
                                                Label(cat.name, systemImage: cat.sfSymbol)
                                            }
                                        }
                                    }
                                }
                                Button(role: .destructive) {
                                    if selectedEvent?.id == event.id {
                                        selectedEvent = nil
                                    }
                                    viewModel.delete(event, context: modelContext)
                                    try? modelContext.save()
                                    HapticManager.medium()
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                }
            }
        }
        .background(AppTheme.background(for: colorScheme))
        .navigationTitle(contentTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { contentToolbar }
        .animation(.easeInOut(duration: 0.2), value: selectedCategoryID)
    }

    private var gridColumns: [GridItem] {
        [GridItem(.flexible())]
    }

    private var contentTitle: String {
        if let id = selectedCategoryID,
           let cat = categories.first(where: { $0.id == id }) {
            return cat.name.uppercased()
        }
        return "ALL EVENTS"
    }

    @ToolbarContentBuilder
    private var contentToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                showingCreateEvent = true
                HapticManager.light()
            } label: {
                Image(systemName: "plus")
                    .fontWeight(.thin)
                    .foregroundStyle(AppTheme.foreground(for: colorScheme))
            }
            .keyboardShortcut("n", modifiers: .command)
        }

        ToolbarItem(placement: .topBarTrailing) {
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

    private var contentEmptyState: some View {
        VStack(spacing: 8) {
            Text("NO EVENTS YET")
                .font(.caption)
                .tracking(4)
                .foregroundStyle(AppTheme.mutedForeground(for: colorScheme))
            Text("Tap + to begin tracking")
                .font(.caption2)
                .foregroundStyle(AppTheme.mutedForeground(for: colorScheme).opacity(0.6))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func category(for event: TrackedEvent) -> EventCategory? {
        guard let id = event.categoryID else { return nil }
        return categories.first(where: { $0.id == id })
    }

    private func handleIncomingURL(_ url: URL) {
        guard let payload = ShareManager.decode(url: url) else { return }
        incomingSharedPayload = payload
        showingSharedConfirm = true
    }
}
