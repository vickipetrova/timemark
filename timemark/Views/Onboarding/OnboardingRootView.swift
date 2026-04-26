import SwiftUI

enum OnboardingScreen: Hashable {
    case concept
    case features
    case final_
}

struct OnboardingRootView: View {
    @State private var path: [OnboardingScreen] = []

    var body: some View {
        NavigationStack(path: $path) {
            OnboardingIntroPage(navigate: navigate)
                .navigationDestination(for: OnboardingScreen.self) { screen in
                    Group {
                        switch screen {
                        case .concept:
                            OnboardingConceptPage(navigate: navigate)
                        case .features:
                            OnboardingFeaturesPage(navigate: navigate)
                        case .final_:
                            OnboardingFinalPage()
                        }
                    }
                    .navigationBarBackButtonHidden(true)
                }
        }
    }

    private func navigate(to screen: OnboardingScreen) {
        path.append(screen)
    }
}

#Preview {
    OnboardingRootView()
}
