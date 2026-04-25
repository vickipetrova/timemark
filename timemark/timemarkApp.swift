import SwiftUI
import SwiftData

@main
struct timemarkApp: App {
    @AppStorage("selectedTheme") private var selectedThemeRaw: String = AppTheme.monochrome.rawValue

    let modelContainer: ModelContainer

    init() {
        let schema = Schema([TrackedEvent.self, EventCategory.self])
        let config = ModelConfiguration(schema: schema, cloudKitDatabase: .automatic)
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
