import SwiftUI
import SwiftData

struct CategoryEventsView: View {
    let category: EventCategory

    @Environment(\.colorScheme) private var colorScheme
    @Query private var events: [TrackedEvent]
    @Query(sort: \EventCategory.sortOrder) private var categories: [EventCategory]

    init(category: EventCategory) {
        self.category = category
        let categoryID = category.id
        _events = Query(
            filter: #Predicate<TrackedEvent> { event in
                event.categoryID == categoryID
            },
            sort: \TrackedEvent.createdAt,
            order: .reverse
        )
    }

    var body: some View {
        Group {
            if events.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(events) { event in
                            NavigationLink(value: event) {
                                EventCardView(event: event, category: category)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                }
            }
        }
        .background(AppTheme.background(for: colorScheme))
        .foregroundStyle(AppTheme.foreground(for: colorScheme))
        .navigationTitle(category.name.uppercased())
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: TrackedEvent.self) { event in
            EventDetailView(event: event)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Text("NO EVENTS IN \(category.name.uppercased())")
                .font(.caption)
                .tracking(4)
                .foregroundStyle(AppTheme.mutedForeground(for: colorScheme))
            Text("Create a new event and assign it to this category")
                .font(.caption2)
                .foregroundStyle(AppTheme.mutedForeground(for: colorScheme).opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
