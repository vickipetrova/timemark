import Foundation
import UserNotifications

@MainActor
final class ReminderManager {
    static let shared = ReminderManager()

    private let center = UNUserNotificationCenter.current()

    private init() {}

    func requestPermissionIfNeeded() async -> Bool {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined:
            do {
                return try await center.requestAuthorization(options: [.alert, .sound, .badge])
            } catch {
                return false
            }
        case .denied:
            return false
        @unknown default:
            return false
        }
    }

    func scheduleReminder(for event: TrackedEvent) async {
        cancelReminder(for: event)

        guard event.reminderEnabled,
              let frequency = event.reminderFrequency,
              let time = event.reminderTime else {
            return
        }

        let granted = await requestPermissionIfNeeded()
        guard granted else { return }

        let content = UNMutableNotificationContent()
        content.title = event.title
        content.body = reminderBody(for: event)
        content.sound = .default

        let calendar = Calendar.current
        var components = calendar.dateComponents([.hour, .minute], from: time)

        switch frequency {
        case .daily:
            break
        case .weekly:
            components.weekday = calendar.component(.weekday, from: event.createdAt)
        case .monthly:
            components.day = calendar.component(.day, from: event.createdAt)
        case .custom:
            break
        }

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: event.id.uuidString,
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
        } catch {
            // Silently fail - user can re-enable later.
        }
    }

    func cancelReminder(for event: TrackedEvent) {
        center.removePendingNotificationRequests(withIdentifiers: [event.id.uuidString])
    }

    func cancelReminder(id: UUID) {
        center.removePendingNotificationRequests(withIdentifiers: [id.uuidString])
    }

    private func reminderBody(for event: TrackedEvent) -> String {
        let result = TimeFormatter.format(
            from: event.eventDate,
            type: event.eventType,
            format: event.displayFormat
        )
        let suffix = event.eventType == .since ? "so far" : "to go"
        if result.unit.isEmpty {
            return "\(result.value) \(suffix)."
        }
        return "\(result.value) \(result.unit) \(suffix)."
    }
}
