import Foundation

enum EventType: String, Codable, CaseIterable, Identifiable {
    case since = "Time Since"
    case until = "Time Until"

    var id: String { rawValue }

    var short: String {
        switch self {
        case .since: return "Since"
        case .until: return "Until"
        }
    }
}

enum DisplayFormat: String, Codable, CaseIterable, Identifiable {
    case days
    case weeks
    case months
    case full
    case auto

    var id: String { rawValue }

    var label: String {
        switch self {
        case .days: return "Days"
        case .weeks: return "Weeks"
        case .months: return "Months"
        case .full: return "Full Breakdown"
        case .auto: return "Auto"
        }
    }
}

enum ReminderFrequency: String, Codable, CaseIterable, Identifiable {
    case daily
    case weekly
    case monthly
    case custom

    var id: String { rawValue }

    var label: String {
        switch self {
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .custom: return "Custom"
        }
    }
}

enum EventSortOrder: String, CaseIterable, Identifiable {
    case dateCreated
    case nameAZ
    case nameZA
    case daysAscending
    case daysDescending
    case manual

    var id: String { rawValue }

    var label: String {
        switch self {
        case .dateCreated: return "Date Created"
        case .nameAZ: return "Name A–Z"
        case .nameZA: return "Name Z–A"
        case .daysAscending: return "Days (Ascending)"
        case .daysDescending: return "Days (Descending)"
        case .manual: return "Manual"
        }
    }

    var systemImage: String {
        switch self {
        case .dateCreated: return "clock"
        case .nameAZ: return "textformat.abc"
        case .nameZA: return "textformat.abc.dottedunderline"
        case .daysAscending: return "arrow.up"
        case .daysDescending: return "arrow.down"
        case .manual: return "hand.draw"
        }
    }
}
