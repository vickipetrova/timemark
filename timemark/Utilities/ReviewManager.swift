import Foundation
import StoreKit
import SwiftUI
import UIKit

@MainActor
@Observable
final class ReviewManager {

    @ObservationIgnored @AppStorage("latestVersionThatReviewWasAskedFor")
    private var latestVersionThatReviewWasAskedFor: String = "1.0"

    @ObservationIgnored @AppStorage("meaningfulActionCount")
    private var meaningfulActionCount: Int = 0

    private static let actionsBeforePrompt = 3

    func recordMeaningfulAction() {
        meaningfulActionCount += 1
        promptIfReady()
    }

    func promptReview() {
        requestReviewIfNewVersion()
    }

    private func promptIfReady() {
        guard meaningfulActionCount >= Self.actionsBeforePrompt else { return }
        requestReviewIfNewVersion()
    }

    private func requestReviewIfNewVersion() {
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        guard currentVersion != latestVersionThatReviewWasAskedFor else { return }

        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            AppStore.requestReview(in: scene)
        }

        latestVersionThatReviewWasAskedFor = currentVersion
    }
}

