import SwiftUI
import WidgetKit

@main
struct TallyDaysWidgetBundle: WidgetBundle {
    var body: some Widget {
        SingleEventWidget()
        MultiEventWidget()
    }
}
