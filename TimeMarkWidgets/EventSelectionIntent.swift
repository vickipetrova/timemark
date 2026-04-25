import AppIntents
import SwiftData
import Foundation

struct TimeMarkEventEntity: AppEntity {
    var id: UUID
    var title: String
    var eventDate: Date
    var eventTypeRaw: String
    var displayFormatRaw: String
    var categoryColorHex: String?

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Event")
    }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)")
    }

    static var defaultQuery = TimeMarkEventQuery()
}

struct TimeMarkEventQuery: EntityQuery {
    func entities(for identifiers: [UUID]) async throws -> [TimeMarkEventEntity] {
        try await fetch(matching: identifiers)
    }

    func suggestedEntities() async throws -> [TimeMarkEventEntity] {
        try await fetch(matching: nil)
    }

    @MainActor
    private func fetch(matching ids: [UUID]?) async throws -> [TimeMarkEventEntity] {
        let schema = Schema([TrackedEvent.self, EventCategory.self])
        let config = ModelConfiguration(schema: schema, cloudKitDatabase: .automatic)
        let container = try ModelContainer(for: schema, configurations: config)
        let context = ModelContext(container)

        let events = try context.fetch(FetchDescriptor<TrackedEvent>())
        let categories = try context.fetch(FetchDescriptor<EventCategory>())

        let filtered: [TrackedEvent]
        if let ids {
            filtered = events.filter { ids.contains($0.id) }
        } else {
            filtered = events
        }

        return filtered.map { event in
            let colorHex = categories.first(where: { $0.id == event.categoryID })?.colorHex
            return TimeMarkEventEntity(
                id: event.id,
                title: event.title,
                eventDate: event.eventDate,
                eventTypeRaw: event.eventType.rawValue,
                displayFormatRaw: event.displayFormat.rawValue,
                categoryColorHex: colorHex
            )
        }
    }
}

struct SelectEventIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Event"
    static var description = IntentDescription("Choose which event to display in the widget.")

    @Parameter(title: "Event")
    var event: TimeMarkEventEntity?
}
