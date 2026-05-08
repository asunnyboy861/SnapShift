import Foundation
import StoreKit
import Combine

@MainActor
class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()

    @Published var isProUnlocked = false
    @Published var isLoading = false

    private let productId = "com.zzoutuo.SnapShift.pro"

    init() {
        Task { await checkPurchaseStatus() }
    }

    func purchase() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let products = try await Product.products(for: [productId])
            guard let product = products.first else { return }
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                switch verification {
                case .verified:
                    isProUnlocked = true
                case .unverified:
                    break
                }
            case .pending, .userCancelled:
                break
            @unknown default:
                break
            }
        } catch {
            print("Purchase error: \(error)")
        }
    }

    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await AppStore.sync()
            await checkPurchaseStatus()
        } catch {
            print("Restore error: \(error)")
        }
    }

    private func checkPurchaseStatus() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == productId {
                    isProUnlocked = transaction.revocationDate == nil
                    await transaction.finish()
                }
            }
        }
    }
}
