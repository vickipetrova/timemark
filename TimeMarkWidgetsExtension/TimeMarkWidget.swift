import SwiftUI
import WidgetKit
import AppIntents
import SwiftData

// MARK: - Timeline Entries

struct SingleEventEntry: TimelineEntry {
    let date: Date
    let event: TallyDaysEventEntity?

    static var placeholder: SingleEventEntry {
        SingleEventEntry(
            date: Date(),
            event: TallyDaysEventEntity(
                id: UUID(),
                title: "Smoke-Free",
                eventDate: Calendar.current.date(byAdding: .day, value: -142, to: Date())!,
                eventTypeRaw: EventType.since.rawValue,
                displayFormatRaw: DisplayFormat.auto.rawValue,
                categoryName: "Health",
                categoryColorHex: "#27AE60"
            )
        )
    }
}

struct MultiEventEntry: TimelineEntry {
    let date: Date
    let events: [TallyDaysEventEntity]

    static func placeholder(for family: WidgetFamily) -> MultiEventEntry {
        let count: Int
        switch family {
        case .systemMedium: count = 3
        case .systemLarge: count = 5
        case .systemExtraLarge: count = 8
        default: count = 3
        }

        let samples: [(String, Int, String, String, String)] = [
            ("Smoke-Free", -142, "Time Since", "Health", "#27AE60"),
            ("Vacation", 27, "Time Until", "Life", "#E74C3C"),
            ("Gym Streak", -18, "Time Since", "Health", "#27AE60"),
            ("Wedding", 180, "Time Until", "Life", "#E74C3C"),
            ("New Job", -365, "Time Since", "Work", "#3498DB"),
            ("Marathon", 60, "Time Until", "Health", "#27AE60"),
            ("Anniversary", -730, "Time Since", "Life", "#E74C3C"),
            ("Exam", 14, "Time Until", "Work", "#3498DB"),
        ]

        let entities = samples.prefix(count).map { (title, offset, type, cat, color) in
            TallyDaysEventEntity(
                id: UUID(),
                title: title,
                eventDate: Calendar.current.date(byAdding: .day, value: offset, to: Date())!,
                eventTypeRaw: type,
                displayFormatRaw: DisplayFormat.auto.rawValue,
                categoryName: cat,
                categoryColorHex: color
            )
        }
        return MultiEventEntry(date: Date(), events: entities)
    }
}

// MARK: - Timeline Providers

struct SingleEventProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SingleEventEntry {
        .placeholder
    }

    func snapshot(for configuration: SelectEventIntent, in context: Context) async -> SingleEventEntry {
        if let entity = configuration.event {
            return SingleEventEntry(date: Date(), event: entity)
        }
        return await fetchFirstEvent() ?? .placeholder
    }

    func timeline(for configuration: SelectEventIntent, in context: Context) async -> Timeline<SingleEventEntry> {
        let entry: SingleEventEntry
        if let entity = configuration.event {
            entry = SingleEventEntry(date: Date(), event: entity)
        } else {
            entry = await fetchFirstEvent() ?? .placeholder
        }
        let midnight = Calendar.current.startOfDay(for: Date()).addingTimeInterval(86400)
        return Timeline(entries: [entry], policy: .after(midnight))
    }

    private func fetchFirstEvent() async -> SingleEventEntry? {
        let container = SharedModelContainer.create()
        let context = ModelContext(container)
        var descriptor = FetchDescriptor<TrackedEvent>(
            sortBy: [SortDescriptor(\.sortOrder)]
        )
        descriptor.fetchLimit = 1
        guard let event = try? context.fetch(descriptor).first else { return nil }
        guard let entity = try? await TallyDaysEventQuery().entities(for: [event.id]).first else { return nil }
        return SingleEventEntry(date: Date(), event: entity)
    }
}

struct MultiEventProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> MultiEventEntry {
        .placeholder(for: context.family)
    }

    func snapshot(for configuration: SelectEventsIntent, in context: Context) async -> MultiEventEntry {
        let max = maxEvents(for: context.family)
        if let entities = configuration.events, !entities.isEmpty {
            return MultiEventEntry(date: Date(), events: Array(entities.prefix(max)))
        }
        return await fetchTopEvents(limit: max) ?? .placeholder(for: context.family)
    }

    func timeline(for configuration: SelectEventsIntent, in context: Context) async -> Timeline<MultiEventEntry> {
        let max = maxEvents(for: context.family)
        let entry: MultiEventEntry
        if let entities = configuration.events, !entities.isEmpty {
            entry = MultiEventEntry(date: Date(), events: Array(entities.prefix(max)))
        } else {
            entry = await fetchTopEvents(limit: max) ?? .placeholder(for: context.family)
        }
        let midnight = Calendar.current.startOfDay(for: Date()).addingTimeInterval(86400)
        return Timeline(entries: [entry], policy: .after(midnight))
    }

    private func maxEvents(for family: WidgetFamily) -> Int {
        switch family {
        case .systemMedium: return 3
        case .systemLarge: return 5
        case .systemExtraLarge: return 8
        default: return 3
        }
    }

    private func fetchTopEvents(limit: Int) async -> MultiEventEntry? {
        let container = SharedModelContainer.create()
        let context = ModelContext(container)
        var descriptor = FetchDescriptor<TrackedEvent>(
            sortBy: [SortDescriptor(\.sortOrder)]
        )
        descriptor.fetchLimit = limit
        guard let events = try? context.fetch(descriptor), !events.isEmpty else { return nil }
        let entities = (try? await TallyDaysEventQuery().entities(for: events.map(\.id))) ?? []
        guard !entities.isEmpty else { return nil }
        return MultiEventEntry(date: Date(), events: entities)
    }
}

// MARK: - Widget Definitions

struct SingleEventWidget: Widget {
    let kind = "TallyDaysSingleEvent"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectEventIntent.self,
            provider: SingleEventProvider()
        ) { entry in
            SingleEventRouterView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Event Counter")
        .description("Display a single event counter.")
        .supportedFamilies([
            .systemSmall,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

struct MultiEventWidget: Widget {
    let kind = "TallyDaysMultiEvent"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectEventsIntent.self,
            provider: MultiEventProvider()
        ) { entry in
            MultiEventRouterView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Event List")
        .description("Display multiple event counters.")
        .supportedFamilies([
            .systemMedium,
            .systemLarge,
            .systemExtraLarge
        ])
    }
}
