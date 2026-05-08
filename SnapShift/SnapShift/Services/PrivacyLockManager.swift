import Foundation
import LocalAuthentication
import Combine

class PrivacyLockManager: ObservableObject {
    static let shared = PrivacyLockManager()

    @Published var isUnlocked = false
    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "privacy_lock_enabled")
        }
    }

    init() {
        self.isEnabled = UserDefaults.standard.bool(forKey: "privacy_lock_enabled")
        if !isEnabled {
            isUnlocked = true
        }
    }

    func authenticate() {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Unlock your progress photos") { success, _ in
                    DispatchQueue.main.async { self.isUnlocked = success }
                }
            }
            return
        }

        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock your progress photos") { success, _ in
            DispatchQueue.main.async { self.isUnlocked = success }
        }
    }

    func lock() {
        if isEnabled {
            isUnlocked = false
        }
    }
}
