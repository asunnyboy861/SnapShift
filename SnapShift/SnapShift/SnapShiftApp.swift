import SwiftUI
import CoreData

@main
struct SnapShiftApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var privacyLock = PrivacyLockManager.shared

    var body: some Scene {
        WindowGroup {
            Group {
                if !hasCompletedOnboarding {
                    OnboardingView()
                } else if privacyLock.isEnabled && !privacyLock.isUnlocked {
                    lockScreen
                } else {
                    mainContent
                }
            }
            .tint(.teal)
        }
    }

    private var mainContent: some View {
        TabView {
            AlbumListView()
                .tabItem {
                    Label("Albums", systemImage: "photo.on.rectangle.angled")
                }

            if let album = firstAlbum {
                TimelineView(album: album)
                    .tabItem {
                        Label("Timeline", systemImage: "calendar")
                    }
            } else {
                Text("Create an album first")
                    .foregroundColor(.secondary)
                    .tabItem {
                        Label("Timeline", systemImage: "calendar")
                    }
            }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }

    private var lockScreen: some View {
        VStack(spacing: 24) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 48))
                .foregroundColor(.teal)
            Text("SnapShift is Locked")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Authenticate to access your progress photos")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Button("Unlock") {
                privacyLock.authenticate()
            }
            .buttonStyle(.borderedProminent)
            .tint(.teal)
        }
    }

    private var firstAlbum: ProgressAlbum? {
        let request: NSFetchRequest<ProgressAlbum> = NSFetchRequest(entityName: "ProgressAlbum")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        request.fetchLimit = 1
        return try? CoreDataStack.shared.viewContext.fetch(request).first
    }
}
