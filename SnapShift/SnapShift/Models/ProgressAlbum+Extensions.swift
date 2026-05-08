import Foundation
import CoreData

extension ProgressAlbum {
    var photoArray: [ProgressPhoto] {
        let set = photos as? Set<ProgressPhoto> ?? []
        return set.sorted { $0.date ?? Date() < $1.date ?? Date() }
    }

    var latestPhoto: ProgressPhoto? {
        photoArray.last
    }

    var photoCount: Int {
        photos?.count ?? 0
    }

    var weekSpan: Int {
        guard let first = photoArray.first?.date,
              let last = photoArray.last?.date else { return 0 }
        return Calendar.current.dateComponents([.weekOfYear], from: first, to: last).weekOfYear ?? 0
    }
}

extension ProgressPhoto {
    var angleEnum: PhotoAngle {
        get {
            PhotoAngle(rawValue: angle ?? "front") ?? .front
        }
        set {
            angle = newValue.rawValue
        }
    }

    var hasImage: Bool {
        imagePath != nil && !imagePath!.isEmpty
    }
}
