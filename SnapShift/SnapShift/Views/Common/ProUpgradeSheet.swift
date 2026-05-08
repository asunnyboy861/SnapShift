import SwiftUI

struct ProUpgradeSheet: View {
    @ObservedObject var purchaseManager = PurchaseManager.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "bolt.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(Color.teal)

            Text("Upgrade to SnapShift Pro")
                .font(.title2)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 12) {
                featureRow("Unlimited albums")
                featureRow("Unlimited photos")
                featureRow("All comparison modes")
                featureRow("Timelapse video")
                featureRow("HealthKit integration")
                featureRow("iCloud sync")
                featureRow("Privacy blur export")
                featureRow("Batch photo import")
            }
            .padding(.horizontal)

            VStack(spacing: 12) {
                Text("$9.99 — One-Time Purchase")
                    .font(.headline)
                    .foregroundStyle(Color.teal)

                Text("No subscriptions. No recurring charges. Forever.")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Button {
                    Task { await purchaseManager.purchase() }
                } label: {
                    if purchaseManager.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Unlock Pro")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.teal)
                .controlSize(.large)

                Button("Restore Purchases") {
                    Task { await purchaseManager.restorePurchases() }
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding(.horizontal)
        }
        .padding()
        .presentationDetents([.large])
        .onChange(of: purchaseManager.isProUnlocked) { _, newValue in
            if newValue { dismiss() }
        }
    }

    private func featureRow(_ text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.teal)
            Text(text)
                .font(.subheadline)
            Spacer()
        }
    }
}
