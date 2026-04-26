import SwiftUI
import SwiftData

struct CreateCategoryView: View {
    enum Mode {
        case create
        case edit(EventCategory)
    }

    let mode: Mode

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.appTheme) private var theme

    @State private var name: String = ""
    @State private var selectedSymbol: String = "heart.fill"
    @State private var selectedHex: String = "#3498DB"

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 6)
    private let colorColumns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 6)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    formSection("NAME") {
                        VStack(spacing: 0) {
                            TextField("Category name", text: $name)
                                .textInputAutocapitalization(.words)
                                .font(.body)
                                .padding(.vertical, 8)
                            Rectangle()
                                .fill(theme.mutedColor)
                                .frame(height: 1)
                        }
                    }

                    formSection("ICON") {
                        LazyVGrid(columns: columns, spacing: 8) {
                            ForEach(EventCategory.symbolOptions, id: \.self) { symbol in
                                Button {
                                    selectedSymbol = symbol
                                    HapticManager.selection()
                                } label: {
                                    Image(systemName: symbol)
                                        .font(.system(size: 20, weight: .light))
                                        .frame(width: 40, height: 40)
                                        .foregroundStyle(
                                            selectedSymbol == symbol
                                                ? theme.accentColor
                                                : AppTheme.foreground(for: colorScheme).opacity(0.6)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 4)
                                                .stroke(
                                                    selectedSymbol == symbol
                                                        ? theme.accentColor
                                                        : Color.clear,
                                                    lineWidth: 1
                                                )
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    formSection("COLOR") {
                        LazyVGrid(columns: colorColumns, spacing: 10) {
                            ForEach(EventCategory.colorOptions, id: \.self) { hex in
                                Button {
                                    selectedHex = hex
                                    HapticManager.selection()
                                } label: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(Color(hex: hex))
                                            .frame(width: 16, height: 16)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 2)
                                                    .stroke(AppTheme.foreground(for: colorScheme).opacity(0.2), lineWidth: 1)
                                            )
                                        if selectedHex == hex {
                                            RoundedRectangle(cornerRadius: 4)
                                                .stroke(theme.accentColor, lineWidth: 1)
                                                .frame(width: 22, height: 22)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 30)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    Button(action: save) {
                        Text("SAVE")
                            .font(.caption.weight(.medium))
                            .tracking(2)
                            .foregroundStyle(theme.accentColor)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(theme.accentColor, lineWidth: 1)
                            )
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    .opacity(name.trimmingCharacters(in: .whitespaces).isEmpty ? 0.4 : 1)

                    if case .edit(let category) = mode {
                        Button {
                            modelContext.delete(category)
                            try? modelContext.save()
                            dismiss()
                        } label: {
                            Text("Delete Category")
                                .font(.caption)
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(20)
            }
            .background(AppTheme.background(for: colorScheme))
            .foregroundStyle(AppTheme.foreground(for: colorScheme))
            .navigationTitle(title.uppercased())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(AppTheme.foreground(for: colorScheme))
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .onAppear(perform: loadIfEditing)
        }
    }

    @ViewBuilder
    private func formSection<Content: View>(_ header: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(header)
                .font(.caption2)
                .tracking(3)
                .foregroundStyle(AppTheme.mutedForeground(for: colorScheme))
            content()
        }
    }

    private var title: String {
        if case .edit = mode { return "Edit Category" }
        return "New Category"
    }

    private func loadIfEditing() {
        if case .edit(let category) = mode {
            name = category.name
            selectedSymbol = category.sfSymbol
            selectedHex = category.colorHex
        }
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        switch mode {
        case .create:
            let sortOrder = (try? modelContext.fetch(FetchDescriptor<EventCategory>()).count) ?? 0
            let category = EventCategory(
                name: trimmed,
                sfSymbol: selectedSymbol,
                colorHex: selectedHex,
                sortOrder: sortOrder
            )
            modelContext.insert(category)
        case .edit(let category):
            category.name = trimmed
            category.sfSymbol = selectedSymbol
            category.colorHex = selectedHex
        }
        try? modelContext.save()
        HapticManager.success()
        dismiss()
    }
}

#Preview {
    CreateCategoryView(mode: .create)
        .modelContainer(for: [EventCategory.self, TrackedEvent.self], inMemory: true)
}
