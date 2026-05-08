import Foundation
import CoreData
import Combine

@MainActor
class AlbumListViewModel: ObservableObject {
    @Published var albums: [ProgressAlbum] = []
    @Published var isProUnlocked = false

    private let context = CoreDataStack.shared.viewContext
    private let purchaseManager = PurchaseManager.shared

    init() {
        isProUnlocked = purchaseManager.isProUnlocked
        fetchAlbums()

        Task {
            for await _ in purchaseManager.$isProUnlocked.values {
                isProUnlocked = purchaseManager.isProUnlocked
            }
        }
    }

    func fetchAlbums() {
        let request: NSFetchRequest<ProgressAlbum> = NSFetchRequest(entityName: "ProgressAlbum")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        do {
            albums = try context.fetch(request)
        } catch {
            print("Fetch albums error: \(error)")
        }
    }

    func canCreateAlbum() -> Bool {
        isProUnlocked || albums.isEmpty
    }

    func createAlbum(name: String) {
        let album = ProgressAlbum(context: context)
        album.id = UUID()
        album.name = name
        album.createdAt = Date()
        CoreDataStack.shared.save()
        fetchAlbums()
    }

    func deleteAlbum(_ album: ProgressAlbum) {
        for photo in album.photoArray {
            PhotoStorageManager.shared.deletePhoto(filename: photo.imagePath)
        }
        context.delete(album)
        CoreDataStack.shared.save()
        fetchAlbums()
    }

    func photosThisWeek(for album: ProgressAlbum) -> Int {
        let calendar = Calendar.current
        let now = Date()
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        return album.photoArray.filter { ($0.date ?? Date()) >= startOfWeek }.count
    }

    func canAddPhoto(to album: ProgressAlbum) -> Bool {
        isProUnlocked || photosThisWeek(for: album) < 3
    }
}
