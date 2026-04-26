import SwiftUI
import WidgetKit

// MARK: - Router Views

struct SingleEventRouterView: View {
    let entry: SingleEventEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .accessoryCircular:
            CircularWidgetView(entry: entry)
        case .accessoryRectangular:
            RectangularWidgetView(entry: entry)
        case .accessoryInline:
            InlineWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

struct MultiEventRouterView: View {
    let entry: MultiEventEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        case .systemExtraLarge:
            ExtraLargeWidgetView(entry: entry)
        default:
            MediumWidgetView(entry: entry)
        }
    }
}

// MARK: - Small Widget

struct SmallWidgetView: View {
    let entry: SingleEventEntry

    var body: some View {
        if let event = entry.event {
            let formatted = widgetFormat(event: event)
            VStack(alignment: .leading, spacing: 0) {
                Rectangle()
                    .fill(categoryColor(for: event))
                    .frame(height: 2)
                    .padding(.bottom, 8)

                Spacer()

                HStack {
                    Spacer()
                    VStack(spacing: 2) {
                        Text(formatted.value)
                            .font(.system(size: 48, weight: .ultraLight, design: .monospaced))
                            .monospacedDigit()
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)

                        if !formatted.unit.isEmpty {
                            Text(formatted.unit.uppercased())
                                .font(.caption2)
                                .tracking(3)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                }

                Spacer()

                VStack(alignment: .leading, spacing: 2) {
                    Text(event.title)
                        .font(.caption.weight(.medium))
                        .lineLimit(1)

                    HStack(spacing: 4) {
                        if let catName = event.categoryName {
                            Text(catName.uppercased())
                                .font(.system(size: 8))
                                .tracking(1.5)
                        }
                        Text("·")
                            .font(.system(size: 8))
                        Text(event.eventTypeRaw == EventType.since.rawValue ? "SINCE" : "UNTIL")
                            .font(.system(size: 8))
                            .tracking(1.5)
                    }
                    .foregroundStyle(.tertiary)
                }
            }
            .widgetURL(URL(string: "tallydays://event/\(event.id.uuidString)"))
        } else {
            emptySmallView
        }
    }

    private var emptySmallView: some View {
        VStack(spacing: 4) {
            Text("NO EVENTS")
                .font(.caption)
                .tracking(4)
                .foregroundStyle(.secondary)
            Text("Add an event in TallyDays")
                .font(.system(size: 8))
                .foregroundStyle(.tertiary)
        }
    }
}

// MARK: - Medium Widget

struct MediumWidgetView: View {
    let entry: MultiEventEntry

    var body: some View {
        if entry.events.isEmpty {
            emptyView
        } else {
            VStack(alignment: .leading, spacing: 0) {
                Text("TALLYDAYS")
                    .font(.system(size: 8))
                    .tracking(3)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 4)

                Rectangle()
                    .fill(WidgetTheme.current.muted)
                    .frame(height: 0.5)
                    .padding(.bottom, 6)

                VStack(spacing: 4) {
                    ForEach(Array(entry.events.prefix(3).enumerated()), id: \.element.id) { index, event in
                        Link(destination: URL(string: "tallydays://event/\(event.id.uuidString)")!) {
                            WidgetEventRow(event: event, compact: false)
                        }
                        if index < min(entry.events.count, 3) - 1 {
                            Rectangle()
                                .fill(WidgetTheme.current.muted.opacity(0.3))
                                .frame(height: 0.5)
                        }
                    }
                }
            }
        }
    }

    private var emptyView: some View {
        VStack(spacing: 4) {
            Text("NO EVENTS")
                .font(.caption)
                .tracking(4)
                .foregroundStyle(.secondary)
            Text("Add events in TallyDays")
                .font(.system(size: 8))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Large Widget

struct LargeWidgetView: View {
    let entry: MultiEventEntry

    var body: some View {
        if entry.events.isEmpty {
            emptyView
        } else {
            VStack(alignment: .leading, spacing: 0) {
                Text("TALLYDAYS")
                    .font(.system(size: 8))
                    .tracking(3)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 4)

                Rectangle()
                    .fill(WidgetTheme.current.muted)
                    .frame(height: 0.5)
                    .padding(.bottom, 4)

                VStack(spacing: 0) {
                    ForEach(Array(entry.events.prefix(5).enumerated()), id: \.element.id) { index, event in
                        Link(destination: URL(string: "tallydays://event/\(event.id.uuidString)")!) {
                            WidgetEventRow(event: event, compact: true)
                                .padding(.vertical, 6)
                        }
                        if index < min(entry.events.count, 5) - 1 {
                            Rectangle()
                                .fill(WidgetTheme.current.muted.opacity(0.3))
                                .frame(height: 0.5)
                        }
                    }
                }

                Spacer(minLength: 0)
            }
        }
    }

    private var emptyView: some View {
        VStack(spacing: 4) {
            Text("NO EVENTS")
                .font(.caption)
                .tracking(4)
                .foregroundStyle(.secondary)
            Text("Add events in TallyDays")
                .font(.system(size: 8))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Extra Large Widget (iPad)

struct ExtraLargeWidgetView: View {
    let entry: MultiEventEntry

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        if entry.events.isEmpty {
            emptyView
        } else {
            VStack(alignment: .leading, spacing: 0) {
                Text("TALLYDAYS")
                    .font(.system(size: 8))
                    .tracking(3)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 6)

                Rectangle()
                    .fill(WidgetTheme.current.muted)
                    .frame(height: 0.5)
                    .padding(.bottom, 8)

                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(Array(entry.events.prefix(8)), id: \.id) { event in
                        Link(destination: URL(string: "tallydays://event/\(event.id.uuidString)")!) {
                            ExtraLargeEventCell(event: event)
                        }
                    }
                }

                Spacer(minLength: 0)
            }
        }
    }

    private var emptyView: some View {
        VStack(spacing: 4) {
            Text("NO EVENTS")
                .font(.caption)
                .tracking(4)
                .foregroundStyle(.secondary)
            Text("Add events in TallyDays")
                .font(.system(size: 8))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct ExtraLargeEventCell: View {
    let event: TallyDaysEventEntity

    var body: some View {
        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 1)
                .fill(categoryColor(for: event))
                .frame(width: 2)
                .padding(.vertical, 4)

            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.caption.weight(.medium))
                    .lineLimit(1)
                if let catName = event.categoryName {
                    Text(catName.uppercased())
                        .font(.system(size: 7))
                        .tracking(1)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.leading, 8)

            Spacer()

            let formatted = widgetFormat(event: event)
            VStack(alignment: .trailing, spacing: 0) {
                Text(formatted.value)
                    .font(.system(size: 20, weight: .ultraLight, design: .monospaced))
                    .monospacedDigit()
                if !formatted.unit.isEmpty {
                    Text(formatted.unit.uppercased())
                        .font(.system(size: 7))
                        .tracking(1.5)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
    }
}

// MARK: - Circular Lock Screen Widget

struct CircularWidgetView: View {
    let entry: SingleEventEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()

            if let event = entry.event {
                let days = dayCount(for: event)
                Text("\(days)")
                    .font(.system(size: 20, weight: .light, design: .monospaced))
                    .monospacedDigit()
                    .widgetAccentable()
                    .privacySensitive()
            } else {
                Text("—")
                    .font(.system(size: 20, weight: .light, design: .monospaced))
            }
        }
    }
}

// MARK: - Rectangular Lock Screen Widget

struct RectangularWidgetView: View {
    let entry: SingleEventEntry

    var body: some View {
        if let event = entry.event {
            let days = dayCount(for: event)
            let label = event.eventTypeRaw == EventType.since.rawValue ? "DAYS SINCE" : "DAYS UNTIL"

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(event.title)
                        .font(.caption.weight(.medium))
                        .lineLimit(1)
                    Spacer()
                    Text("\(days)")
                        .font(.system(size: 20, weight: .light, design: .monospaced))
                        .monospacedDigit()
                        .widgetAccentable()
                }
                Text(label)
                    .font(.system(size: 8))
                    .tracking(1.5)
                    .foregroundStyle(.secondary)
            }
            .privacySensitive()
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            VStack(alignment: .leading, spacing: 2) {
                Text("TallyDays")
                    .font(.caption.weight(.medium))
                Text("NO EVENT SELECTED")
                    .font(.system(size: 8))
                    .tracking(1.5)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Inline Lock Screen Widget

struct InlineWidgetView: View {
    let entry: SingleEventEntry

    var body: some View {
        if let event = entry.event {
            let days = dayCount(for: event)
            let unit = days == 1 ? "day" : "days"
            Text("\(Image(systemName: "clock")) \(event.title): \(days) \(unit)")
        } else {
            Text("TallyDays")
        }
    }
}

// MARK: - Reusable Row

struct WidgetEventRow: View {
    let event: TallyDaysEventEntity
    let compact: Bool

    var body: some View {
        let formatted = widgetFormat(event: event)

        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 1)
                .fill(categoryColor(for: event))
                .frame(width: 2)
                .padding(.vertical, compact ? 2 : 4)

            VStack(alignment: .leading, spacing: 1) {
                Text(event.title)
                    .font(.caption.weight(.medium))
                    .lineLimit(1)

                if !compact, let catName = event.categoryName {
                    Text(catName.uppercased())
                        .font(.system(size: 8))
                        .tracking(1)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.leading, 8)

            Spacer()

            VStack(alignment: .trailing, spacing: 0) {
                Text(formatted.value)
                    .font(.system(size: compact ? 20 : 24, weight: .ultraLight, design: .monospaced))
                    .monospacedDigit()

                if !formatted.unit.isEmpty {
                    Text(formatted.unit.uppercased())
                        .font(.system(size: 7))
                        .tracking(1.5)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

// MARK: - Helpers

private func dayCount(for event: TallyDaysEventEntity) -> Int {
    let now = Calendar.current.startOfDay(for: Date())
    let eventDay = Calendar.current.startOfDay(for: event.eventDate)
    if event.eventTypeRaw == EventType.since.rawValue {
        return max(0, Calendar.current.dateComponents([.day], from: eventDay, to: now).day ?? 0)
    } else {
        return max(0, Calendar.current.dateComponents([.day], from: now, to: eventDay).day ?? 0)
    }
}

private func categoryColor(for event: TallyDaysEventEntity) -> Color {
    if let hex = event.categoryColorHex {
        return Color(hex: hex)
    }
    return WidgetTheme.current.accent
}

private func widgetFormat(event: TallyDaysEventEntity) -> (value: String, unit: String) {
    let type = WidgetEventType(rawValue: event.eventTypeRaw) ?? .since
    let format = WidgetDisplayFormat(rawValue: event.displayFormatRaw) ?? .auto
    return WidgetTimeFormatter.format(from: event.eventDate, type: type, format: format)
}

private enum WidgetEventType: String {
    case since = "Time Since"
    case until = "Time Until"
}

private enum WidgetDisplayFormat: String {
    case days
    case weeks
    case months
    case full
    case auto
}

private enum WidgetTimeFormatter {
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
            let w = totalDays / 7
            return ("\(w)", w == 1 ? "week" : "weeks")
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
