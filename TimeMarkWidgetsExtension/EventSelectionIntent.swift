import AppIntents
import SwiftData
import Foundation

struct TallyDaysEventEntity: AppEntity {
    var id: UUID
    var title: String
    var eventDate: Date
    var eventTypeRaw: String
    var displayFormatRaw: String
    var categoryName: String?
    var categoryColorHex: String?

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Event")
    }

    var displayRepresentation: DisplayRepresentation {
        let typeLabel = eventTypeRaw == EventType.since.rawValue ? "Since" : "Until"
        return DisplayRepresentation(
            title: "\(title)",
            subtitle: "\(typeLabel) \(eventDate.formatted(date: .abbreviated, time: .omitted))"
        )
    }

    static var defaultQuery = TallyDaysEventQuery()
}

struct TallyDaysEventQuery: EntityQuery {
    func entities(for identifiers: [UUID]) async throws -> [TallyDaysEventEntity] {
        try await fetchEntities(matching: identifiers)
    }

    func suggestedEntities() async throws -> [TallyDaysEventEntity] {
        try await fetchEntities(matching: nil)
    }

    @MainActor
    private func fetchEntities(matching ids: [UUID]?) throws -> [TallyDaysEventEntity] {
        let container = SharedModelContainer.create()
        let context = ModelContext(container)
        let events = try context.fetch(
            FetchDescriptor<TrackedEvent>(sortBy: [SortDescriptor(\.sortOrder)])
        )
        let categories = try context.fetch(FetchDescriptor<EventCategory>())

        let filtered: [TrackedEvent]
        if let ids {
            filtered = events.filter { ids.contains($0.id) }
        } else {
            filtered = events
        }

        return filtered.map { event in
            let category = categories.first(where: { $0.id == event.categoryID })
            return TallyDaysEventEntity(
                id: event.id,
                title: event.title,
                eventDate: event.eventDate,
                eventTypeRaw: event.eventType.rawValue,
                displayFormatRaw: event.displayFormat.rawValue,
                categoryName: category?.name,
                categoryColorHex: category?.colorHex
            )
        }
    }
}

struct SelectEventIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Event"
    static var description = IntentDescription("Choose which event to display in the widget.")

    @Parameter(title: "Event")
    var event: TallyDaysEventEntity?
}

struct SelectEventsIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Events"
    static var description = IntentDescription("Choose events to display in the widget.")

    @Parameter(title: "Events")
    var events: [TallyDaysEventEntity]?
}
