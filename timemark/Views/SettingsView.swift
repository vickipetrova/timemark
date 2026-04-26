import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SettingsView: View {
    @AppStorage("selectedTheme") private var selectedThemeRaw: String = AppTheme.monochrome.rawValue
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.appTheme) private var theme
    @Query private var events: [TrackedEvent]
    @Query(sort: \EventCategory.sortOrder) private var categories: [EventCategory]

    @State private var exportDocument: ExportDocument?
    @State private var showingExporter = false
    @State private var showingImporter = false
    @State private var importMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                settingsSection("APPEARANCE") {
                    ForEach(AppTheme.allCases) { t in
                        Button {
                            selectedThemeRaw = t.rawValue
                            HapticManager.light()
                        } label: {
                            HStack(spacing: 12) {
                                Group {
                                    if t.isSpectrum {
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color(hex: "#E74C3C"), Color(hex: "#F39C12"), Color(hex: "#27AE60"), Color(hex: "#3498DB")],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 12, height: 12)
                                    } else {
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(t.accentColor(for: colorScheme))
                                            .frame(width: 12, height: 12)
                                    }
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 2)
                                        .stroke(AppTheme.foreground(for: colorScheme).opacity(0.2), lineWidth: 1)
                                )
                                Text(t.label)
                                    .font(.body)
                                    .foregroundStyle(AppTheme.foreground(for: colorScheme))
                                Spacer()
                                if selectedThemeRaw == t.rawValue {
                                    Image(systemName: "checkmark")
                                        .font(.caption2)
                                        .foregroundStyle(theme.accentColor(for: colorScheme))
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        if t.rawValue != AppTheme.allCases.last?.rawValue {
                            Rectangle()
                                .fill(theme.mutedColor(for: colorScheme).opacity(0.3))
                                .frame(height: 0.5)
                        }
                    }
                }

                settingsSection("DATA") {
                    HStack {
                        Text("iCloud Sync")
                            .font(.body)
                        Spacer()
                        Text("Automatic")
                            .font(.body)
                            .foregroundStyle(AppTheme.mutedForeground(for: colorScheme))
                    }

                    Rectangle()
                        .fill(theme.mutedColor(for: colorScheme).opacity(0.3))
                        .frame(height: 0.5)

                    Button {
                        prepareExport()
                    } label: {
                        Text("Export Data")
                            .font(.body)
                            .foregroundStyle(AppTheme.foreground(for: colorScheme))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)

                    Rectangle()
                        .fill(theme.mutedColor(for: colorScheme).opacity(0.3))
                        .frame(height: 0.5)

                    Button {
                        showingImporter = true
                    } label: {
                        Text("Import Data")
                            .font(.body)
                            .foregroundStyle(AppTheme.foreground(for: colorScheme))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                }

                settingsSection("ABOUT") {
                    HStack {
                        Text("Version")
                            .font(.body)
                        Spacer()
                        Text(appVersion)
                            .font(.body)
                            .foregroundStyle(AppTheme.mutedForeground(for: colorScheme))
                    }

                    Rectangle()
                        .fill(theme.mutedColor(for: colorScheme).opacity(0.3))
                        .frame(height: 0.5)

//                    Link(destination: URL(string: "https://apps.apple.com")!) {
//                        Text("Rate on App Store")
//                            .font(.body)
//                            .foregroundStyle(AppTheme.foreground(for: colorScheme))
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                    }

                    Rectangle()
                        .fill(theme.mutedColor(for: colorScheme).opacity(0.3))
                        .frame(height: 0.5)

                    Link(destination: URL(string: "mailto:victoria_petrowa@icloud.com")!) {
                        Text("Contact Developer")
                            .font(.body)
                            .foregroundStyle(AppTheme.foreground(for: colorScheme))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Rectangle()
                        .fill(theme.mutedColor(for: colorScheme).opacity(0.3))
                        .frame(height: 0.5)

                    Link(destination: URL(string: "https://timemark.app/privacy")!) {
                        Text("Privacy Policy")
                            .font(.body)
                            .foregroundStyle(AppTheme.foreground(for: colorScheme))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(20)
        }
        .background(AppTheme.background(for: colorScheme))
        .foregroundStyle(AppTheme.foreground(for: colorScheme))
        .navigationTitle("SETTINGS")
        .navigationBarTitleDisplayMode(.inline)
        .fileExporter(
            isPresented: $showingExporter,
            document: exportDocument,
            contentType: .json,
            defaultFilename: "TimeMarkExport"
        ) { _ in }
        .fileImporter(
            isPresented: $showingImporter,
            allowedContentTypes: [.json]
        ) { result in
            handleImport(result: result)
        }
        .alert(
            "Import",
            isPresented: Binding(
                get: { importMessage != nil },
                set: { if !$0 { importMessage = nil } }
            )
        ) {
            Button("OK") { importMessage = nil }
        } message: {
            Text(importMessage ?? "")
        }
    }

    @ViewBuilder
    private func settingsSection<Content: View>(_ header: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(header)
                .font(.caption2)
                .tracking(3)
                .foregroundStyle(AppTheme.mutedForeground(for: colorScheme))
            content()
        }
    }

    private var appVersion: String {
        let marketing = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(marketing) (\(build))"
    }

    private func prepareExport() {
        let payload = ExportPayload(
            events: events.map { ExportedEvent(event: $0) },
            categories: categories.map { ExportedCategory(category: $0) }
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(payload) {
            exportDocument = ExportDocument(data: data)
            showingExporter = true
        }
    }

    private func handleImport(result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            let didAccess = url.startAccessingSecurityScopedResource()
            defer {
                if didAccess { url.stopAccessingSecurityScopedResource() }
            }
            guard let data = try? Data(contentsOf: url) else {
                importMessage = "Couldn't read file."
                return
            }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            guard let payload = try? decoder.decode(ExportPayload.self, from: data) else {
                importMessage = "Invalid backup file."
                return
            }

            var categoryMap: [UUID: UUID] = [:]
            for exported in payload.categories {
                let category = EventCategory(
                    name: exported.name,
                    sfSymbol: exported.sfSymbol,
                    colorHex: exported.colorHex,
                    sortOrder: exported.sortOrder
                )
                modelContext.insert(category)
                categoryMap[exported.id] = category.id
            }

            for exported in payload.events {
                let remappedCategoryID = exported.categoryID.flatMap { categoryMap[$0] }
                let event = TrackedEvent(
                    title: exported.title,
                    eventDate: exported.eventDate,
                    eventType: EventType(rawValue: exported.eventTypeRaw) ?? .since,
                    displayFormat: DisplayFormat(rawValue: exported.displayFormatRaw) ?? .auto,
                    categoryID: remappedCategoryID,
                    sortOrder: exported.sortOrder,
                    dateHistory: exported.dateHistory
                )
                modelContext.insert(event)
            }

            try? modelContext.save()
            importMessage = "Imported \(payload.events.count) events."
        case .failure(let error):
            importMessage = error.localizedDescription
        }
    }
}

private struct ExportPayload: Codable {
    var events: [ExportedEvent]
    var categories: [ExportedCategory]
}

private struct ExportedEvent: Codable {
    var id: UUID
    var title: String
    var eventDate: Date
    var eventTypeRaw: String
    var displayFormatRaw: String
    var categoryID: UUID?
    var sortOrder: Int
    var dateHistory: [Date]

    init(event: TrackedEvent) {
        self.id = event.id
        self.title = event.title
        self.eventDate = event.eventDate
        self.eventTypeRaw = event.eventType.rawValue
        self.displayFormatRaw = event.displayFormat.rawValue
        self.categoryID = event.categoryID
        self.sortOrder = event.sortOrder
        self.dateHistory = event.dateHistory
    }
}

private struct ExportedCategory: Codable {
    var id: UUID
    var name: String
    var sfSymbol: String
    var colorHex: String
    var sortOrder: Int

    init(category: EventCategory) {
        self.id = category.id
        self.name = category.name
        self.sfSymbol = category.sfSymbol
        self.colorHex = category.colorHex
        self.sortOrder = category.sortOrder
    }
}

private struct ExportDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }

    var data: Data

    init(data: Data) { self.data = data }

    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}
