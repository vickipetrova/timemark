import SwiftUI
import SwiftData

struct CreateEventView: View {
    enum Mode {
        case create
        case edit(TrackedEvent)
    }

    let mode: Mode
    var prefilled: SharedEventPayload?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.appTheme) private var theme
    @Query(sort: \EventCategory.sortOrder) private var categories: [EventCategory]

    @State private var title: String = ""
    @State private var eventType: EventType = .since
    @State private var date: Date = Date()
    @State private var categoryID: UUID? = nil
    @State private var displayFormat: DisplayFormat = .auto
    @State private var reminderEnabled: Bool = false
    @State private var reminderFrequency: ReminderFrequency = .daily
    @State private var reminderTime: Date = defaultReminderTime()

    @State private var showDeleteConfirm: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    formSection("TITLE") {
                        VStack(spacing: 0) {
                            TextField("e.g. Quit smoking", text: $title)
                                .textInputAutocapitalization(.sentences)
                                .font(.body)
                                .padding(.vertical, 8)
                            Rectangle()
                                .fill(theme.mutedColor)
                                .frame(height: 1)
                        }
                    }

                    formSection("TYPE") {
                        Picker("Type", selection: $eventType) {
                            ForEach(EventType.allCases) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    formSection("DATE") {
                        DatePicker(
                            eventType == .since ? "Start date" : "Target date",
                            selection: $date,
                            displayedComponents: .date
                        )
                        .font(.body)
                    }

                    formSection("CATEGORY") {
                        Picker("Category", selection: $categoryID) {
                            Text("None").tag(UUID?.none)
                            ForEach(categories) { category in
                                HStack {
                                    Image(systemName: category.sfSymbol)
                                    Text(category.name)
                                }
                                .tag(UUID?.some(category.id))
                            }
                        }
                        .pickerStyle(.menu)
                    }

                    formSection("DISPLAY FORMAT") {
                        Picker("Format", selection: $displayFormat) {
                            ForEach(DisplayFormat.allCases) { format in
                                Text(format.label).tag(format)
                            }
                        }
                        .pickerStyle(.menu)
                    }

                    formSection("REMINDER") {
                        VStack(alignment: .leading, spacing: 12) {
                            Toggle(isOn: $reminderEnabled) {
                                Text("Enabled")
                                    .font(.body)
                            }
                            .toggleStyle(.switch)

                            if reminderEnabled {
                                Picker("Frequency", selection: $reminderFrequency) {
                                    ForEach(ReminderFrequency.allCases.filter { $0 != .custom }) { freq in
                                        Text(freq.label).tag(freq)
                                    }
                                }
                                .pickerStyle(.menu)

                                DatePicker(
                                    "Time",
                                    selection: $reminderTime,
                                    displayedComponents: .hourAndMinute
                                )
                            }
                        }
                    }

                    Button(action: save) {
                        Text("SAVE")
                            .font(.caption.weight(.medium))
                            .tracking(2)
                            .foregroundStyle(theme.accentColor)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(theme.accentColor, lineWidth: 1)
                            )
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                    .opacity(title.trimmingCharacters(in: .whitespaces).isEmpty ? 0.4 : 1)

                    if case .edit = mode {
                        Button {
                            showDeleteConfirm = true
                        } label: {
                            Text("Delete Event")
                                .font(.caption)
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(20)
            }
            .background(AppTheme.background(for: colorScheme))
            .foregroundStyle(AppTheme.foreground(for: colorScheme))
            .navigationTitle(navTitle.uppercased())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(AppTheme.foreground(for: colorScheme))
                }
            }
            .presentationDetents([.large])
            .onAppear(perform: loadDefaults)
            .confirmationDialog(
                "Delete this event?",
                isPresented: $showDeleteConfirm,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive, action: performDelete)
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    @ViewBuilder
    private func formSection<Content: View>(_ header: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(header)
                .font(.caption2)
                .tracking(3)
                .foregroundStyle(AppTheme.mutedForeground(for: colorScheme))
            content()
        }
    }

    private var navTitle: String {
        if case .edit = mode { return "Edit Event" }
        return "New Event"
    }

    private func loadDefaults() {
        switch mode {
        case .edit(let event):
            title = event.title
            eventType = event.eventType
            date = event.eventDate
            categoryID = event.categoryID
            displayFormat = event.displayFormat
            reminderEnabled = event.reminderEnabled
            reminderFrequency = event.reminderFrequency ?? .daily
            reminderTime = event.reminderTime ?? Self.defaultReminderTime()
        case .create:
            if let prefilled {
                title = prefilled.title
                date = prefilled.eventDate
                eventType = EventType(rawValue: prefilled.eventTypeRaw) ?? .since
                displayFormat = DisplayFormat(rawValue: prefilled.displayFormatRaw) ?? .auto
            } else {
                date = eventType == .since ? Date() : Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
            }
        }
    }

    private func save() {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        let resolvedFrequency: ReminderFrequency? = reminderEnabled ? reminderFrequency : nil
        let resolvedTime: Date? = reminderEnabled ? reminderTime : nil

        switch mode {
        case .create:
            let sortOrder = (try? modelContext.fetch(FetchDescriptor<TrackedEvent>()).count) ?? 0
            let event = TrackedEvent(
                title: trimmed,
                eventDate: date,
                eventType: eventType,
                displayFormat: displayFormat,
                categoryID: categoryID,
                sortOrder: sortOrder,
                reminderEnabled: reminderEnabled,
                reminderFrequency: resolvedFrequency,
                reminderTime: resolvedTime
            )
            modelContext.insert(event)
            try? modelContext.save()
            Task { await ReminderManager.shared.scheduleReminder(for: event) }

        case .edit(let event):
            event.title = trimmed
            event.eventDate = date
            event.eventType = eventType
            event.displayFormat = displayFormat
            event.categoryID = categoryID
            event.reminderEnabled = reminderEnabled
            event.reminderFrequency = resolvedFrequency
            event.reminderTime = resolvedTime
            try? modelContext.save()
            Task { await ReminderManager.shared.scheduleReminder(for: event) }
        }

        HapticManager.success()
        dismiss()
    }

    private func performDelete() {
        if case .edit(let event) = mode {
            ReminderManager.shared.cancelReminder(for: event)
            modelContext.delete(event)
            try? modelContext.save()
            HapticManager.medium()
            dismiss()
        }
    }

    private static func defaultReminderTime() -> Date {
        var components = DateComponents()
        components.hour = 9
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
}

#Preview {
    CreateEventView(mode: .create)
        .modelContainer(for: [EventCategory.self, TrackedEvent.self], inMemory: true)
}
