//
//  ReviewManager.swift
//  timemark
//
//  Created by Victoria Petrova on 26/04/2026.
//

import Foundation
import StoreKit
import SwiftUI
import UIKit
import Combine

class ReviewManager: ObservableObject {

    @AppStorage("latestVersionThatReviewWasAskedFor") var latestVersionThatReviewWasAskedFor: String = "1.0"

    func promptReviewAlert() {
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"

        if currentVersion == latestVersionThatReviewWasAskedFor {
            return
        }

        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            AppStore.requestReview(in: scene)
        }

        latestVersionThatReviewWasAskedFor = currentVersion
    }
}

