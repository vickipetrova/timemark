import Foundation

struct TimeFormatter {
    static func format(
        from date: Date,
        type: EventType,
        format: DisplayFormat,
        reference: Date = Date()
    ) -> (value: String, unit: String) {
        let startOfDate = Calendar.current.startOfDay(for: date)
        let startOfReference = Calendar.current.startOfDay(for: reference)
        let earlier = min(startOfDate, startOfReference)
        let later = max(startOfDate, startOfReference)

        let totalDays: Int
        switch type {
        case .since:
            totalDays = max(0, Calendar.current.dateComponents([.day], from: startOfDate, to: startOfReference).day ?? 0)
        case .until:
            totalDays = max(0, Calendar.current.dateComponents([.day], from: startOfReference, to: startOfDate).day ?? 0)
        }

        switch format {
        case .days:
            return ("\(totalDays)", totalDays == 1 ? "day" : "days")

        case .weeks:
            let weeks = totalDays / 7
            return ("\(weeks)", weeks == 1 ? "week" : "weeks")

        case .months:
            let components = Calendar.current.dateComponents([.month], from: earlier, to: later)
            let months = components.month ?? 0
            return ("\(months)", months == 1 ? "month" : "months")

        case .full:
            let components = Calendar.current.dateComponents([.year, .month, .day], from: earlier, to: later)
            var parts: [String] = []
            if let y = components.year, y > 0 { parts.append("\(y)y") }
            if let m = components.month, m > 0 { parts.append("\(m)m") }
            if let d = components.day, d > 0 { parts.append("\(d)d") }
            if parts.isEmpty { parts.append("0d") }
            return (parts.joined(separator: " "), "")

        case .auto:
            if totalDays < 7 {
                return ("\(totalDays)", totalDays == 1 ? "day" : "days")
            }
            if totalDays < 30 {
                let weeks = totalDays / 7
                return ("\(weeks)", weeks == 1 ? "week" : "weeks")
            }
            if totalDays < 365 {
                let months = Calendar.current.dateComponents([.month], from: earlier, to: later).month ?? 0
                return ("\(months)", months == 1 ? "month" : "months")
            }
            let comps = Calendar.current.dateComponents([.year, .month], from: earlier, to: later)
            let y = comps.year ?? 0
            let m = comps.month ?? 0
            if m == 0 {
                return ("\(y)y", "")
            }
            return ("\(y)y \(m)m", "")
        }
    }

    static func directionalLabel(for type: EventType, days: Int) -> String {
        switch type {
        case .since:
            if days == 0 { return "today" }
            return days == 1 ? "day ago" : "days ago"
        case .until:
            if days == 0 { return "today" }
            return days == 1 ? "day left" : "days left"
        }
    }
}
