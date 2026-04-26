# TimeMark Widget Extension — Setup

The Swift files in this directory are the complete widget extension code for TimeMark. The main app builds without them; they live outside `timemark/` because a widget is a **separate target** and can't be mixed with the app's sources.

## One-time Xcode setup

1. **Create the widget extension target**
   - `File → New → Target… → Widget Extension`
   - Product name: `TimeMarkWidgets`
   - Uncheck "Include Configuration Intent" and "Include Live Activity"
   - Finish. Xcode will add scaffolding; delete the generated `TimeMarkWidgets.swift`, `AppIntent.swift`, and `TimeMarkWidgetsBundle.swift` — replace them with the files in this folder.

2. **Add the files in `TimeMarkWidgets/` to the new target**
   - Drag `TimeMarkWidgetBundle.swift`, `TimeMarkWidget.swift`, `WidgetViews.swift`, `EventSelectionIntent.swift` into the widget target in Xcode.
   - Ensure they're only members of the widget target, not the main app.

3. **Share model + utility files with the widget target**
   The widget reads the same SwiftData store, so it needs the model classes. In Xcode's file inspector, enable **Target Membership** for the widget target on:
   - `timemark/Models/TrackedEvent.swift`
   - `timemark/Models/EventCategory.swift`
   - `timemark/Models/Enums.swift`
   - `timemark/Extensions/Color+Hex.swift`

4. **Enable App Groups** on both targets
   Signing & Capabilities → `+` → App Groups → add `group.vickipetrova.timemark` to both `timemark` and `TimeMarkWidgets`. Then update `TimeMarkApp.init()` to use a grouped `ModelConfiguration` URL if you want true cross-process sharing. With CloudKit sync enabled, this is optional — the widget's `ModelContainer` will see the same iCloud-synced data.

5. **Enable iCloud (CloudKit)** on the main app target
   Signing & Capabilities → `+` → iCloud → CloudKit; create a container e.g. `iCloud.vickipetrova.timemark`.

6. **Enable Push Notifications + Background Modes → Remote notifications** on the main app target (required for CloudKit push).

## Additional Info.plist keys for the main app

The main app auto-generates its Info.plist (`GENERATE_INFOPLIST_FILE = YES`). To register the URL scheme for event sharing, add these `INFOPLIST_KEY_*` build settings to the `timemark` target, **or** turn off auto-generation and paste the snippet into a custom Info.plist:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>vickipetrova.timemark</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>timemark</string>
        </array>
    </dict>
</array>
<key>NSUserNotificationsUsageDescription</key>
<string>TimeMark sends optional reminders for the events you track.</string>
```
