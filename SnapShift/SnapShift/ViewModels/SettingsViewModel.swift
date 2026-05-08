import Foundation
import SwiftUI
import Combine

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var isProUnlocked = false
    @Published var isPrivacyLockEnabled = false
    @Published var isHealthKitEnabled = false
    @Published var isLoading = false

    private let purchaseManager = PurchaseManager.shared
    private let privacyLock = PrivacyLockManager.shared
    private let healthKit = HealthKitManager.shared

    let supportURL = "https://asunnyboy861.github.io/SnapShift/support.html"
    let privacyURL = "https://asunnyboy861.github.io/SnapShift/privacy.html"
    let termsURL = "https://asunnyboy861.github.io/SnapShift/terms.html"

    init() {
        isProUnlocked = purchaseManager.isProUnlocked
        isPrivacyLockEnabled = privacyLock.isEnabled
        isHealthKitEnabled = healthKit.isAuthorized
    }

    func purchasePro() async {
        await purchaseManager.purchase()
        isProUnlocked = purchaseManager.isProUnlocked
    }

    func restorePurchases() async {
        await purchaseManager.restorePurchases()
        isProUnlocked = purchaseManager.isProUnlocked
    }

    func togglePrivacyLock() {
        privacyLock.isEnabled.toggle()
        isPrivacyLockEnabled = privacyLock.isEnabled
    }

    func toggleHealthKit() async {
        if !isHealthKitEnabled {
            await healthKit.requestAuthorization()
            isHealthKitEnabled = healthKit.isAuthorized
        }
    }
}
