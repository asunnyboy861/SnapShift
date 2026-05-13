import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showingProSheet = false
    @State private var showingContactSupport = false

    var body: some View {
        NavigationStack {
            Form {
                proSection
                privacySection
                aboutSection
                supportSection
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingProSheet) {
                ProUpgradeSheet()
            }
            .sheet(isPresented: $showingContactSupport) {
                ContactSupportView()
            }
        }
    }

    private var proSection: some View {
        Section {
            if viewModel.isProUnlocked {
                HStack {
                    Image(systemName: "bolt.circle.fill")
                        .foregroundColor(.teal)
                    Text("SnapShift Pro")
                        .fontWeight(.medium)
                    Spacer()
                    Text("Active")
                        .foregroundColor(.green)
                }
            } else {
                Button {
                    showingProSheet = true
                } label: {
                    HStack {
                        Image(systemName: "bolt.circle")
                            .foregroundColor(.teal)
                        Text("Upgrade to Pro")
                            .foregroundColor(.primary)
                        Spacer()
                        Text("$9.99")
                            .foregroundColor(.secondary)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        } header: {
            Text("Pro Features")
        }
    }

    private var privacySection: some View {
        Section {
            Toggle(isOn: $viewModel.isPrivacyLockEnabled) {
                Label("Privacy Lock", systemImage: "lock.shield")
            }
            .onChange(of: viewModel.isPrivacyLockEnabled) { _, _ in
                viewModel.togglePrivacyLock()
            }
        } header: {
            Text("Privacy")
        }
    }

    private var aboutSection: some View {
        Section {
            Link(destination: URL(string: viewModel.privacyURL)!) {
                Label("Privacy Policy", systemImage: "hand.raised")
            }
            Link(destination: URL(string: viewModel.termsURL)!) {
                Label("Terms of Use", systemImage: "doc.text")
            }
        } header: {
            Text("Legal")
        }
    }

    private var supportSection: some View {
        Section {
            Button {
                showingContactSupport = true
            } label: {
                Label("Contact Support", systemImage: "envelope")
            }
            Button {
                Task { await viewModel.restorePurchases() }
            } label: {
                Label("Restore Purchases", systemImage: "arrow.uturn.down")
            }
        } header: {
            Text("Support")
        }
    }
}
