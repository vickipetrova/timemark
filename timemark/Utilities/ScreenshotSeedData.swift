#if DEBUG
import Foundation
import SwiftData

struct ScreenshotSeedData {

    static var isEnabled: Bool {
        ProcessInfo.processInfo.arguments.contains("-seedScreenshotData")
    }

    @MainActor
    static func seed(in context: ModelContext) {
        wipeAll(in: context)

        let categories = seedCategories(in: context)
        let life = categories["Life"]!
        let work = categories["Work"]!
        let health = categories["Health"]!
        let personal = categories["Personal"]!

        let events: [(String, EventType, Int, UUID, DisplayFormat)] = [
            ("Quit smoking",          .since,  142, health.id,   .auto),
            ("Last haircut",          .since,   37, personal.id, .days),
            ("Started this job",      .since,  891, work.id,     .full),
            ("Wedding anniversary",   .since,  204, life.id,     .auto),
            ("Dentist checkup",       .since,  183, health.id,   .days),
            ("Family vacation",       .until,   58, life.id,     .auto),
            ("Marathon",              .until,   21, health.id,   .days),
            ("Project deadline",      .until,   12, work.id,     .days),
            ("Concert tickets",       .until,   34, personal.id, .auto),
            ("Moved to new city",     .since,  412, life.id,     .full),
            ("Last coffee",           .since,    3, health.id,   .days),
            ("Book club meetup",      .until,    5, personal.id, .days),
        ]

        for (index, e) in events.enumerated() {
            let date: Date
            if e.1 == .since {
                date = Calendar.current.date(byAdding: .day, value: -e.2, to: .now)!
            } else {
                date = Calendar.current.date(byAdding: .day, value: e.2, to: .now)!
            }

            let event = TrackedEvent(
                title: e.0,
                eventDate: date,
                eventType: e.1,
                displayFormat: e.4,
                categoryID: e.3,
                sortOrder: index
            )
            context.insert(event)
        }

        try? context.save()
    }

    @MainActor
    private static func seedCategories(in context: ModelContext) -> [String: EventCategory] {
        var map: [String: EventCategory] = [:]
        for (index, seed) in EventCategory.defaultSeed.enumerated() {
            let category = EventCategory(
                name: seed.name,
                sfSymbol: seed.symbol,
                colorHex: seed.hex,
                sortOrder: index
            )
            context.insert(category)
            map[seed.name] = category
        }
        return map
    }

    @MainActor
    private static func wipeAll(in context: ModelContext) {
        try? context.delete(model: TrackedEvent.self)
        try? context.delete(model: EventCategory.self)
    }
}
#endif
