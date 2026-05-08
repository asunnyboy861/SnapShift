import Foundation
import UIKit

class PhotoStorageManager {
    static let shared = PhotoStorageManager()

    private var photosDirectory: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dir = docs.appendingPathComponent("ProgressPhotos", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    func savePhoto(_ image: UIImage, for photoId: UUID) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.85) else { return nil }
        let filename = "\(photoId.uuidString).jpg"
        let url = photosDirectory.appendingPathComponent(filename)
        do {
            try data.write(to: url)
            return filename
        } catch {
            print("Failed to save photo: \(error)")
            return nil
        }
    }

    func loadPhoto(filename: String?) -> UIImage? {
        guard let filename = filename else { return nil }
        let url = photosDirectory.appendingPathComponent(filename)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    func deletePhoto(filename: String?) {
        guard let filename = filename else { return }
        let url = photosDirectory.appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: url)
    }

    func thumbnail(filename: String?, size: CGSize) -> UIImage? {
        guard let full = loadPhoto(filename: filename) else { return nil }
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            full.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
