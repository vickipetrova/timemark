import SwiftUI
import SwiftData

struct EventCardView: View {
    let event: TrackedEvent
    let category: EventCategory?

    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let formatted = TimeFormatter.format(
            from: event.eventDate,
            type: event.eventType,
            format: event.displayFormat
        )
        let directionLabel = TimeFormatter.directionalLabel(
            for: event.eventType,
            days: event.daysCount
        )
        let muted = AppTheme.mutedForeground(for: colorScheme)
        let fg = AppTheme.foreground(for: colorScheme)

        HStack(alignment: .center, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline.weight(.semibold))
                    .lineLimit(1)
                    .foregroundStyle(fg)

                HStack(spacing: 4) {
                    if let category {
                        Text(category.name)
                            .font(.caption)
                            .foregroundStyle(muted)
                        Text("·")
                            .font(.caption)
                            .foregroundStyle(muted)
                    }
                    Text(event.eventType.short)
                        .font(.caption)
                        .foregroundStyle(muted)
                }
            }

            Spacer(minLength: 12)

            VStack(alignment: .trailing, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    if event.eventType == .until {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .ultraLight))
                            .foregroundStyle(muted)
                    }
                    Text(formatted.value)
                        .font(.system(size: 36, weight: .ultraLight, design: .monospaced))
                        .foregroundStyle(fg)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }

                Text(unitLabel(formatted: formatted, direction: directionLabel))
                    .font(.caption2)
                    .tracking(2)
                    .textCase(.uppercase)
                    .foregroundStyle(muted)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(Color.clear)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(theme.mutedColor, lineWidth: 1)
        )
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(event.title))
        .accessibilityValue(Text("\(formatted.value) \(formatted.unit)"))
    }

    private func unitLabel(formatted: (value: String, unit: String), direction: String) -> String {
        if formatted.unit.isEmpty {
            return direction
        }
        return formatted.unit
    }
}
