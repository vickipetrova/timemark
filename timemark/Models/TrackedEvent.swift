import Foundation
import SwiftData

@Model
final class TrackedEvent {
    var id: UUID = UUID()
    var title: String = ""
    var eventDate: Date = Date()
    private var eventTypeRaw: String = EventType.since.rawValue
    var createdAt: Date = Date()
    private var displayFormatRaw: String = DisplayFormat.auto.rawValue
    var categoryID: UUID?
    var sortOrder: Int = 0
    var reminderEnabled: Bool = false
    private var reminderFrequencyRaw: String?
    var reminderTime: Date?
    var dateHistory: [Date] = []
    var shareCode: String?

    init(
        id: UUID = UUID(),
        title: String,
        eventDate: Date = Date(),
        eventType: EventType = .since,
        createdAt: Date = Date(),
        displayFormat: DisplayFormat = .auto,
        categoryID: UUID? = nil,
        sortOrder: Int = 0,
        reminderEnabled: Bool = false,
        reminderFrequency: ReminderFrequency? = nil,
        reminderTime: Date? = nil,
        dateHistory: [Date] = [],
        shareCode: String? = nil
    ) {
        self.id = id
        self.title = title
        self.eventDate = eventDate
        self.eventTypeRaw = eventType.rawValue
        self.createdAt = createdAt
        self.displayFormatRaw = displayFormat.rawValue
        self.categoryID = categoryID
        self.sortOrder = sortOrder
        self.reminderEnabled = reminderEnabled
        self.reminderFrequencyRaw = reminderFrequency?.rawValue
        self.reminderTime = reminderTime
        self.dateHistory = dateHistory
        self.shareCode = shareCode
    }

    var eventType: EventType {
        get { EventType(rawValue: eventTypeRaw) ?? .since }
        set { eventTypeRaw = newValue.rawValue }
    }

    var displayFormat: DisplayFormat {
        get { DisplayFormat(rawValue: displayFormatRaw) ?? .auto }
        set { displayFormatRaw = newValue.rawValue }
    }

    var reminderFrequency: ReminderFrequency? {
        get { reminderFrequencyRaw.flatMap { ReminderFrequency(rawValue: $0) } }
        set { reminderFrequencyRaw = newValue?.rawValue }
    }

    var daysCount: Int {
        let now = Date()
        let reference = eventType == .since ? eventDate : now
        let target = eventType == .since ? now : eventDate
        let components = Calendar.current.dateComponents(
            [.day],
            from: reference.startOfDay,
            to: target.startOfDay
        )
        return max(0, components.day ?? 0)
    }
}
