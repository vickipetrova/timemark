import SwiftUI
import SwiftData
import WidgetKit

extension Notification.Name {
    static let createEvent = Notification.Name("createEvent")
    static let createCategory = Notification.Name("createCategory")
    static let openSettings = Notification.Name("openSettings")
}

@main
struct tallydaysApp: App {
    @AppStorage("selectedTheme", store: UserDefaults(suiteName: SharedModelContainer.appGroupID))
    private var selectedThemeRaw: String = AppTheme.monochrome.rawValue

    let modelContainer: ModelContainer

    init() {
        let schema = Schema([TrackedEvent.self, EventCategory.self])
        let config = ModelConfiguration(
            schema: schema,
            url: SharedModelContainer.containerURL,
            cloudKitDatabase: .automatic
        )
        do {
            modelContainer = try ModelContainer(for: schema, configurations: config)
        } catch {
            let fallback = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            do {
                modelContainer = try ModelContainer(for: schema, configurations: fallback)
            } catch {
                fatalError("Unable to create ModelContainer: \(error)")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.appTheme, AppTheme(rawValue: selectedThemeRaw) ?? .monochrome)
                .tint(AppTheme(rawValue: selectedThemeRaw)?.accent ?? AppTheme.monochrome.accent)
                .task { await seedDefaultCategoriesIfNeeded() }
                .task { _ = await ReminderManager.shared.requestPermissionIfNeeded() }
        }
        .modelContainer(modelContainer)
        .defaultSize(width: 1100, height: 700)
        .commands {
            CommandGroup(after: .newItem) {
                Button("New Event") {
                    NotificationCenter.default.post(name: .createEvent, object: nil)
                }
                .keyboardShortcut("n", modifiers: .command)

                Button("New Category") {
                    NotificationCenter.default.post(name: .createCategory, object: nil)
                }
                .keyboardShortcut("k", modifiers: .command)
            }
            CommandGroup(replacing: .appSettings) {
                Button("Settings...") {
                    NotificationCenter.default.post(name: .openSettings, object: nil)
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }
    }

    @MainActor
    private func seedDefaultCategoriesIfNeeded() async {
        let context = modelContainer.mainContext
        let descriptor = FetchDescriptor<EventCategory>()
        guard let existing = try? context.fetch(descriptor), existing.isEmpty else { return }

        for (index, seed) in EventCategory.defaultSeed.enumerated() {
            let category = EventCategory(
                name: seed.name,
                sfSymbol: seed.symbol,
                colorHex: seed.hex,
                sortOrder: index
            )
            context.insert(category)
        }

        try? context.save()
    }
}
