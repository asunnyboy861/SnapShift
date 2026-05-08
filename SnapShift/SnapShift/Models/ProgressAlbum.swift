import Foundation
import CoreData

@objc(ProgressAlbum)
class ProgressAlbum: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var name: String?
    @NSManaged var createdAt: Date?
    @NSManaged var cameraPosition: Int16
    @NSManaged var reminderDay: Int16
    @NSManaged var reminderTime: Date?
    @NSManaged var photos: NSSet?
}

@objc(ProgressPhoto)
class ProgressPhoto: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var angle: String?
    @NSManaged var date: Date?
    @NSManaged var imagePath: String?
    @NSManaged var weight: Double
    @NSManaged var bodyFat: Double
    @NSManaged var muscleMass: Double
    @NSManaged var notes: String?
    @NSManaged var album: ProgressAlbum?
}
