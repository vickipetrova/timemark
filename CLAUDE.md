# TimeMark — Notes for Future Claude

Minimalist iOS app that counts days since / until life events. SwiftUI + SwiftData + CloudKit, no third-party deps.

## Project layout

- `timemark/` — app target. Auto-synced via `PBXFileSystemSynchronizedRootGroup` in `project.pbxproj`. **Any file you drop inside is automatically a member of the target** — you do not need to edit `project.pbxproj` to add Swift files.
- `TimeMarkWidgets/` — widget extension sources, deliberately outside `timemark/` because widgets must be a separate target. Not yet wired up; `TimeMarkWidgets/README.md` has the one-time Xcode steps.
- `timemark.xcodeproj/` — single app target called `timemark`, bundle id `vickipetrova.timemark`, deployment target `iOS 26.0`.

Inside `timemark/`: `Models/`, `Views/`, `ViewModels/`, `Utilities/`, `Extensions/`, `Assets.xcassets/`, plus `timemarkApp.swift` at the root.

## Build & verify

```bash
xcodebuild -project timemark.xcodeproj -scheme timemark \
  -configuration Debug -destination 'generic/platform=iOS Simulator' -quiet build
```

This is the authoritative source of truth — **SourceKit diagnostics in this project are extremely noisy and usually wrong**. A cascade of "Cannot find type 'X' in scope" will appear for almost every file after you add a new one, but `xcodebuild` will happily report `BUILD SUCCEEDED`. Always confirm with a real build before chasing a SourceKit error.

## Project-specific gotchas

- **`MemberImportVisibility` is on** (`SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY = YES`). Transitive imports do not leak members — if you use `UIColor`, `UIImpactFeedbackGenerator`, etc., you must `import UIKit` explicitly, even though `import SwiftUI` seems to pull it in. SourceKit sometimes reports `No such module 'UIKit'` as a false positive; the build succeeds.
- **Default actor isolation is `MainActor`** (`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`). Synchronous closures passed to `.map { ExportedEvent(event: $0) }` work, but `events.map(ExportedEvent.init)` triggers an "isolated initializer in nonisolated context" warning because the reference-to-init loses the main-actor context.
- **`SortOrder` is a reserved-feeling name** — Foundation/SwiftData define their own `SortOrder`. Ours is `EventSortOrder` to avoid ambiguity.
- **SwiftData + CloudKit requires defaults on every stored property.** All `@Model` properties in `TrackedEvent` and `EventCategory` have defaults (or are optional). Don't add a non-optional stored property without a default — CloudKit sync will break.
- **Enums stored on SwiftData models use raw `String` backing** (`eventTypeRaw`, `displayFormatRaw`, `reminderFrequencyRaw`) with computed `EventType`/`DisplayFormat` accessors. This keeps the CloudKit schema stable if the enum gains cases.
- **SwiftUI semantic colors** (`Color(.secondarySystemBackground)` etc.) work without explicit UIKit import in this project because they're resolved via the SwiftUI overlay. Stick with those rather than `Color(UIColor.secondarySystemBackground)`.
- **First-launch CoreData log spam is expected.** On first launch, SwiftData logs a wall of `Sandbox access to file-write-create denied` / `component is not writeable with errno 1` / `addPersistentStoreWithType... returned error NSCocoaErrorDomain (512)` — this is CoreData's self-heal: `Library/Application Support` doesn't exist, the store add fails, CoreData creates the directory and retries, then logs `Recovery attempt... was successful!`. Subsequent launches are silent. Do not "fix" this by pre-creating directories; the recovery path is the intended behavior.

## Architecture conventions

- `@Observable` for view models (iOS 17 Observation, not `ObservableObject`).
- `@AppStorage` only for primitive preferences (`selectedTheme`, `sortOrder`). Never for model data.
- `@Query` in views, sorted with SwiftData key paths.
- Theme is injected via a custom `\.appTheme` environment key (see `Models/AppTheme.swift`). `AppTheme.onAccentText(for: ColorScheme)` is a method, not a property, because enums can't read `@Environment`.
- `HapticManager` is a pure `enum` with static methods, requires `import UIKit`.
- Widget target, when added, must share `Models/`, `Extensions/Color+Hex.swift` via Target Membership — don't duplicate those files.

## What's not yet wired up

All code compiles, but these capabilities require Xcode UI work (documented in `TimeMarkWidgets/README.md`):
- URL scheme registration (`timemark://`) — `onOpenURL` handler is already in `MainView`, just needs `CFBundleURLTypes` in the generated Info.plist.
- iCloud / CloudKit capability on the app target.
- Push Notifications + Background Modes → Remote notifications (for CloudKit push).
- App Groups (`group.vickipetrova.timemark`).
- Widget Extension target creation and file assignment.

If the user asks "why isn't sharing working" or "why don't widgets show up", it's almost certainly because one of the above capabilities hasn't been added — check there before debugging code.
