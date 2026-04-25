import Foundation

struct SharedEventPayload: Codable {
    var title: String
    var eventDate: Date
    var eventTypeRaw: String
    var displayFormatRaw: String
}

enum ShareManager {
    static let urlScheme = "timemark"
    static let urlHost = "import"

    static func makeShareURL(for event: TrackedEvent) -> URL? {
        let payload = SharedEventPayload(
            title: event.title,
            eventDate: event.eventDate,
            eventTypeRaw: event.eventType.rawValue,
            displayFormatRaw: event.displayFormat.rawValue
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        guard let data = try? encoder.encode(payload) else { return nil }
        let base64 = data.base64EncodedString()

        var components = URLComponents()
        components.scheme = urlScheme
        components.host = urlHost
        components.queryItems = [URLQueryItem(name: "data", value: base64)]
        return components.url
    }

    static func makeShareMessage(for event: TrackedEvent) -> String {
        let formatted = TimeFormatter.format(
            from: event.eventDate,
            type: event.eventType,
            format: event.displayFormat
        )
        let time = formatted.unit.isEmpty
            ? formatted.value
            : "\(formatted.value) \(formatted.unit)"
        switch event.eventType {
        case .since:
            return "I've been tracking '\(event.title)' for \(time) using TimeMark."
        case .until:
            return "Tracking \(time) until '\(event.title)' with TimeMark."
        }
    }

    static func decode(url: URL) -> SharedEventPayload? {
        guard url.scheme == urlScheme,
              url.host == urlHost else { return nil }

        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        guard let base64 = components?.queryItems?.first(where: { $0.name == "data" })?.value,
              let data = Data(base64Encoded: base64) else { return nil }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(SharedEventPayload.self, from: data)
    }

    static func shareCode() -> String {
        String(UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(10)).uppercased()
    }
}
