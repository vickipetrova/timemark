import SwiftUI
import WidgetKit

struct TimeMarkWidgetView: View {
    @Environment(\.widgetFamily) private var family
    var entry: TimeMarkEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallTimeMarkView(entry: entry)
        case .systemMedium:
            MediumTimeMarkView(entry: entry)
        case .systemLarge:
            LargeTimeMarkView(entry: entry)
        case .accessoryCircular:
            CircularAccessoryView(entry: entry)
        case .accessoryRectangular:
            RectangularAccessoryView(entry: entry)
        case .accessoryInline:
            InlineAccessoryView(entry: entry)
        default:
            SmallTimeMarkView(entry: entry)
        }
    }
}

private struct SmallTimeMarkView: View {
    let entry: TimeMarkEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Rectangle()
                .fill(eventAccentColor(for: entry.event))
                .frame(height: 3)

            Spacer()

            Text(entry.event?.title ?? "TimeMark")
                .font(.caption.weight(.bold))
                .lineLimit(2)

            Spacer()

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(valueString(for: entry.event))
                    .font(.system(.largeTitle, design: .monospaced).weight(.ultraLight))
                    .monospacedDigit()
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                Text(unitString(for: entry.event))
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

private struct MediumTimeMarkView: View {
    let entry: TimeMarkEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(events.prefix(3), id: \.id) { event in
                row(event: event)
                Divider().opacity(0.3)
            }
        }
    }

    private var events: [TimeMarkEventEntity] {
        var all: [TimeMarkEventEntity] = []
        if let primary = entry.event { all.append(primary) }
        all.append(contentsOf: entry.additionalEvents)
        return all
    }

    private func row(event: TimeMarkEventEntity) -> some View {
        HStack {
            Rectangle()
                .fill(eventAccentColor(for: event))
                .frame(width: 3, height: 28)
            Text(event.title)
                .font(.callout.weight(.semibold))
                .lineLimit(1)
            Spacer()
            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text(valueString(for: event))
                    .font(.system(.title3, design: .monospaced).weight(.ultraLight))
                    .monospacedDigit()
                Text(unitString(for: event))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct LargeTimeMarkView: View {
    let entry: TimeMarkEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(events.prefix(5), id: \.id) { event in
                HStack {
                    Rectangle()
                        .fill(eventAccentColor(for: event))
                        .frame(width: 3, height: 36)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(event.title)
                            .font(.body.weight(.semibold))
                            .lineLimit(1)
                        Text(event.eventDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    HStack(alignment: .firstTextBaseline, spacing: 3) {
                        Text(valueString(for: event))
                            .font(.system(.title2, design: .monospaced).weight(.ultraLight))
                            .monospacedDigit()
                        Text(unitString(for: event))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                Divider().opacity(0.25)
            }
        }
    }

    private var events: [TimeMarkEventEntity] {
        var all: [TimeMarkEventEntity] = []
        if let primary = entry.event { all.append(primary) }
        all.append(contentsOf: entry.additionalEvents)
        return all
    }
}

private struct CircularAccessoryView: View {
    let entry: TimeMarkEntry

    var body: some View {
        VStack(spacing: 0) {
            Text(valueString(for: entry.event))
                .font(.system(.title3, design: .monospaced).weight(.ultraLight))
                .monospacedDigit()
            Text(unitString(for: entry.event))
                .font(.system(size: 8, weight: .semibold))
        }
    }
}

private struct RectangularAccessoryView: View {
    let entry: TimeMarkEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(entry.event?.title ?? "TimeMark")
                .font(.caption2.weight(.semibold))
                .lineLimit(1)
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(valueString(for: entry.event))
                    .font(.system(.title3, design: .monospaced).weight(.ultraLight))
                    .monospacedDigit()
                Text(unitString(for: entry.event))
                    .font(.caption2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct InlineAccessoryView: View {
    let entry: TimeMarkEntry

    var body: some View {
        if let event = entry.event {
            Text("\(event.title): \(valueString(for: event)) \(unitString(for: event))")
        } else {
            Text("TimeMark")
        }
    }
}

private func valueString(for event: TimeMarkEventEntity?) -> String {
    guard let event else { return "0" }
    return widgetFormat(event: event).value
}

private func unitString(for event: TimeMarkEventEntity?) -> String {
    guard let event else { return "days" }
    let unit = widgetFormat(event: event).unit
    return unit.isEmpty ? "" : unit
}

private func eventAccentColor(for event: TimeMarkEventEntity?) -> Color {
    if let hex = event?.categoryColorHex {
        return Color(hex: hex)
    }
    return .primary
}

private func widgetFormat(event: TimeMarkEventEntity) -> (value: String, unit: String) {
    let type = WidgetEventType(rawValue: event.eventTypeRaw) ?? .since
    let format = WidgetDisplayFormat(rawValue: event.displayFormatRaw) ?? .auto
    return WidgetTimeFormatter.format(from: event.eventDate, type: type, format: format)
}

enum WidgetEventType: String {
    case since = "Time Since"
    case until = "Time Until"
}

enum WidgetDisplayFormat: String {
    case days
    case weeks
    case months
    case full
    case auto
}

enum WidgetTimeFormatter {
    static func format(
        from date: Date,
        type: WidgetEventType,
        format: WidgetDisplayFormat,
        reference: Date = Date()
    ) -> (value: String, unit: String) {
        let start = Calendar.current.startOfDay(for: date)
        let ref = Calendar.current.startOfDay(for: reference)
        let earlier = min(start, ref)
        let later = max(start, ref)

        let totalDays: Int
        switch type {
        case .since:
            totalDays = max(0, Calendar.current.dateComponents([.day], from: start, to: ref).day ?? 0)
        case .until:
            totalDays = max(0, Calendar.current.dateComponents([.day], from: ref, to: start).day ?? 0)
        }

        switch format {
        case .days:
            return ("\(totalDays)", totalDays == 1 ? "day" : "days")
        case .weeks:
            let weeks = totalDays / 7
            return ("\(weeks)", weeks == 1 ? "week" : "weeks")
        case .months:
            let m = Calendar.current.dateComponents([.month], from: earlier, to: later).month ?? 0
            return ("\(m)", m == 1 ? "month" : "months")
        case .full:
            let c = Calendar.current.dateComponents([.year, .month, .day], from: earlier, to: later)
            var parts: [String] = []
            if let y = c.year, y > 0 { parts.append("\(y)y") }
            if let m = c.month, m > 0 { parts.append("\(m)m") }
            if let d = c.day, d > 0 { parts.append("\(d)d") }
            if parts.isEmpty { parts.append("0d") }
            return (parts.joined(separator: " "), "")
        case .auto:
            if totalDays < 7 { return ("\(totalDays)", totalDays == 1 ? "day" : "days") }
            if totalDays < 30 { let w = totalDays / 7; return ("\(w)", w == 1 ? "week" : "weeks") }
            if totalDays < 365 {
                let m = Calendar.current.dateComponents([.month], from: earlier, to: later).month ?? 0
                return ("\(m)", m == 1 ? "month" : "months")
            }
            let c = Calendar.current.dateComponents([.year, .month], from: earlier, to: later)
            let y = c.year ?? 0
            let m = c.month ?? 0
            return (m == 0 ? "\(y)y" : "\(y)y \(m)m", "")
        }
    }
}
