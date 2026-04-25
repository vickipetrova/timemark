import Foundation
import SwiftData
import SwiftUI

@Observable
final class EventsViewModel {
    var searchText: String = ""

    func sort(_ events: [TrackedEvent], by order: EventSortOrder) -> [TrackedEvent] {
        switch order {
        case .dateCreated:
            return events.sorted { $0.createdAt > $1.createdAt }
        case .nameAZ:
            return events.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .nameZA:
            return events.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedDescending }
        case .daysAscending:
            return events.sorted { $0.daysCount < $1.daysCount }
        case .daysDescending:
            return events.sorted { $0.daysCount > $1.daysCount }
        case .manual:
            return events.sorted { $0.sortOrder < $1.sortOrder }
        }
    }

    func filter(_ events: [TrackedEvent], categoryID: UUID?) -> [TrackedEvent] {
        guard let categoryID else { return events }
        return events.filter { $0.categoryID == categoryID }
    }

    func eventCount(in events: [TrackedEvent], for categoryID: UUID?) -> Int {
        if let categoryID {
            return events.filter { $0.categoryID == categoryID }.count
        }
        return events.count
    }

    func reorder(events: inout [TrackedEvent], from source: IndexSet, to destination: Int) {
        events.move(fromOffsets: source, toOffset: destination)
        for (index, event) in events.enumerated() {
            event.sortOrder = index
        }
    }

    func resetEvent(_ event: TrackedEvent) {
        event.dateHistory.append(event.eventDate)
        if event.eventType == .since {
            event.eventDate = Date()
        }
    }

    func delete(_ event: TrackedEvent, context: ModelContext) {
        ReminderManager.shared.cancelReminder(for: event)
        context.delete(event)
    }

    func delete(_ category: EventCategory, events: [TrackedEvent], context: ModelContext) {
        for event in events where event.categoryID == category.id {
            event.categoryID = nil
        }
        context.delete(category)
    }
}
