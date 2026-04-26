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
- **Custom `Date` extensions exist in `Extensions/Date+Helpers.swift`.** The project defines helpers like `.startOfDay` on `Date`. Before "fixing" a `Date` API that looks unfamiliar, check the Extensions folder — it's probably already defined there. Do not replace custom extensions with `Calendar.current` equivalents.
- **First-launch CoreData log spam is expected.** On first launch, SwiftData logs a wall of `Sandbox access to file-write-create denied` / `component is not writeable with errno 1` / `addPersistentStoreWithType... returned error NSCocoaErrorDomain (512)` — this is CoreData's self-heal: `Library/Application Support` doesn't exist, the store add fails, CoreData creates the directory and retries, then logs `Recovery attempt... was successful!`. Subsequent launches are silent. Do not "fix" this by pre-creating directories; the recovery path is the intended behavior.

## Architecture conventions

- `@Observable` for view models (iOS 17 Observation, not `ObservableObject`).
- `@AppStorage` only for primitive preferences (`selectedTheme`, `sortOrder`). Never for model data.
- `@Query` in views, sorted with SwiftData key paths.
- Theme is injected via a custom `\.appTheme` environment key (see `Models/AppTheme.swift`). `AppTheme.onAccentText(for: ColorScheme)` is a method, not a property, because enums can't read `@Environment`.
- `HapticManager` is a pure `enum` with static methods, requires `import UIKit`. All haptics use `.impact(.light)` — nothing heavier.
- Widget target, when added, must share `Models/`, `Extensions/Color+Hex.swift` via Target Membership — don't duplicate those files.

## Design system — Palantir-inspired minimalism

The UI follows a strict dark-first, typographic, high-contrast visual language. Every new view or component must conform to these rules.

### Color system (`AppTheme.swift`)
- Five muted institutional themes: `monochrome`, `slate`, `forest`, `oxide`, `steel`.
- Each theme exposes `accentColor`, `primaryColor`, `mutedColor` (accent at 50% opacity).
- Backgrounds are **never** pure black/white — use `AppTheme.background(for:)` (`#0A0A0A` dark / `#FAFAFA` light).
- Text uses `AppTheme.foreground(for:)` (`#E8E8E8` dark / `#1A1A1A` light) and `AppTheme.mutedForeground(for:)` for secondary text.
- **Do not use** `Color(.systemBackground)`, `Color(.secondarySystemBackground)`, `.primary`, or `.secondary` — always use the static `AppTheme` methods so colors are consistent across light/dark.

### Typography rules
- **Typography is the UI.** Hierarchy is solved with weight, size, and letter-spacing — not color fills or shadows.
- All headings, section headers, button labels, and pill text are **ALL CAPS** with `.tracking()`.
- Day counts and numbers use `.monospacedDigit()` or `.design(.monospaced)` with `.ultraLight` weight.
- Reference table:
  - App title: `.caption`, `.medium`, UPPER, `.tracking(4)`
  - Section headers: `.caption2`, `.regular`, UPPER, `.tracking(3)`
  - Category pills: `.caption2`, `.medium`, UPPER, `.tracking(1.5)`
  - Event card title: `.headline`, `.semibold`, title case, no tracking
  - Day count (card): `.system(size: 36, weight: .ultraLight, design: .monospaced)`
  - Day count (detail): `.system(size: 72, weight: .ultraLight, design: .monospaced)`
  - Buttons: `.caption`, `.medium`, UPPER, `.tracking(2)`

### Shape & layout rules
- **Outlines over fills.** Buttons, cards, pills use 1pt borders with clear fill. The only filled elements are: selected category pill (accent at 10% opacity) and destructive buttons.
- Corner radius: **4pt** everywhere. No rounded bubbly corners.
- **No shadows, no gradients, no blur materials.** No `.thinMaterial`, no `.shadow()`.
- Card-to-card spacing: 8pt. Internal padding: 16pt vertical, 20pt horizontal.
- Generous whitespace — minimum 16-20pt padding on all containers.
- Dividers are thin `Rectangle()` fills using `theme.mutedColor` at 1pt or 0.5pt — not SwiftUI `Divider()`.

### Interaction rules
- All transitions use `.opacity` or `.easeInOut(duration: 0.2)`. No springs, no bounces.
- Press states: border color change only (muted → accent). No scale transforms.
- SF Symbols always use `.thin` or `.light` weight — never filled variants.

### Form/sheet conventions
- Sheets use `.presentationDetents([.large])` — always full height.
- No `Form` / grouped list style. Build forms with `ScrollView` + `VStack` + custom `formSection()` helper.
- Text fields: no background, just a 1pt bottom border (underline input style).
- Section headers: ALL CAPS `.caption2` with `.tracking(3)` in muted color.
- Save button: full-width outline style at bottom. Delete: plain red text, no border.

### Empty states
- Text only — no illustrations, icons, or decorative elements.
- Title: `.caption`, ALL CAPS, `.tracking(4)`, muted color.
- Subtitle: `.caption2`, even more muted.

## What's not yet wired up

All code compiles, but these capabilities require Xcode UI work (documented in `TimeMarkWidgets/README.md`):
- URL scheme registration (`timemark://`) — `onOpenURL` handler is already in `MainView`, just needs `CFBundleURLTypes` in the generated Info.plist.
- iCloud / CloudKit capability on the app target.
- Push Notifications + Background Modes → Remote notifications (for CloudKit push).
- App Groups (`group.vickipetrova.timemark`).
- Widget Extension target creation and file assignment.

If the user asks "why isn't sharing working" or "why don't widgets show up", it's almost certainly because one of the above capabilities hasn't been added — check there before debugging code.
