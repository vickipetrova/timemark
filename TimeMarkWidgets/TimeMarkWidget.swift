import SwiftUI
import WidgetKit
import AppIntents

struct TimeMarkEntry: TimelineEntry {
    let date: Date
    let event: TimeMarkEventEntity?
    let additionalEvents: [TimeMarkEventEntity]
}

struct TimeMarkProvider: AppIntentTimelineProvider {
    typealias Entry = TimeMarkEntry
    typealias Intent = SelectEventIntent

    func placeholder(in context: Context) -> TimeMarkEntry {
        TimeMarkEntry(date: Date(), event: Self.sampleEvent, additionalEvents: [])
    }

    func snapshot(for configuration: SelectEventIntent, in context: Context) async -> TimeMarkEntry {
        let events = (try? await TimeMarkEventQuery().suggestedEntities()) ?? []
        let primary = configuration.event ?? events.first ?? Self.sampleEvent
        let remainder = events.filter { $0.id != primary.id }
        return TimeMarkEntry(date: Date(), event: primary, additionalEvents: remainder)
    }

    func timeline(for configuration: SelectEventIntent, in context: Context) async -> Timeline<TimeMarkEntry> {
        let entry = await snapshot(for: configuration, in: context)
        let next = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date().addingTimeInterval(3600)
        return Timeline(entries: [entry], policy: .after(next))
    }

    static let sampleEvent = TimeMarkEventEntity(
        id: UUID(),
        title: "New Event",
        eventDate: Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date(),
        eventTypeRaw: "Time Since",
        displayFormatRaw: "auto",
        categoryColorHex: nil
    )
}

struct TimeMarkWidget: Widget {
    let kind: String = "TimeMarkWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectEventIntent.self,
            provider: TimeMarkProvider()
        ) { entry in
            TimeMarkWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("TimeMark")
        .description("Track the time since or until your most important events.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}
