import SwiftData
import Foundation

enum SharedModelContainer {
    static let appGroupID = "group.vickipetrova.tallydays"

    static func create() -> ModelContainer {
        let schema = Schema([TrackedEvent.self, EventCategory.self])
        let config = ModelConfiguration(
            schema: schema,
            url: containerURL,
            cloudKitDatabase: .none
        )
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create shared ModelContainer: \(error)")
        }
    }

    static var containerURL: URL {
        let appGroupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID
        )!
        return appGroupURL.appendingPathComponent("TallyDays.store")
    }

    static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }
}
