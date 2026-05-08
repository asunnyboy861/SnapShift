import Foundation
import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()

    lazy var managedObjectModel: NSManagedObjectModel = {
        let model = NSManagedObjectModel()

        let albumEntity = NSEntityDescription()
        albumEntity.name = "ProgressAlbum"
        albumEntity.managedObjectClassName = "ProgressAlbum"

        let albumId = NSAttributeDescription()
        albumId.name = "id"
        albumId.attributeType = .UUIDAttributeType
        albumId.isOptional = true

        let albumName = NSAttributeDescription()
        albumName.name = "name"
        albumName.attributeType = .stringAttributeType
        albumName.isOptional = true

        let albumCreatedAt = NSAttributeDescription()
        albumCreatedAt.name = "createdAt"
        albumCreatedAt.attributeType = .dateAttributeType
        albumCreatedAt.isOptional = true

        let albumCameraPosition = NSAttributeDescription()
        albumCameraPosition.name = "cameraPosition"
        albumCameraPosition.attributeType = .integer16AttributeType
        albumCameraPosition.isOptional = true
        albumCameraPosition.defaultValue = 0

        let albumReminderDay = NSAttributeDescription()
        albumReminderDay.name = "reminderDay"
        albumReminderDay.attributeType = .integer16AttributeType
        albumReminderDay.isOptional = true
        albumReminderDay.defaultValue = 0

        let albumReminderTime = NSAttributeDescription()
        albumReminderTime.name = "reminderTime"
        albumReminderTime.attributeType = .dateAttributeType
        albumReminderTime.isOptional = true

        let photosRelationship = NSRelationshipDescription()
        photosRelationship.name = "photos"
        photosRelationship.destinationEntity = albumEntity
        photosRelationship.isOptional = true
        photosRelationship.maxCount = 0
        photosRelationship.deleteRule = .cascadeDeleteRule

        albumEntity.properties = [
            albumId, albumName, albumCreatedAt, albumCameraPosition,
            albumReminderDay, albumReminderTime, photosRelationship
        ]

        let photoEntity = NSEntityDescription()
        photoEntity.name = "ProgressPhoto"
        photoEntity.managedObjectClassName = "ProgressPhoto"

        let photoId = NSAttributeDescription()
        photoId.name = "id"
        photoId.attributeType = .UUIDAttributeType
        photoId.isOptional = true

        let photoAngle = NSAttributeDescription()
        photoAngle.name = "angle"
        photoAngle.attributeType = .stringAttributeType
        photoAngle.isOptional = true

        let photoDate = NSAttributeDescription()
        photoDate.name = "date"
        photoDate.attributeType = .dateAttributeType
        photoDate.isOptional = true

        let photoImagePath = NSAttributeDescription()
        photoImagePath.name = "imagePath"
        photoImagePath.attributeType = .stringAttributeType
        photoImagePath.isOptional = true

        let photoWeight = NSAttributeDescription()
        photoWeight.name = "weight"
        photoWeight.attributeType = .doubleAttributeType
        photoWeight.isOptional = true
        photoWeight.defaultValue = 0.0

        let photoBodyFat = NSAttributeDescription()
        photoBodyFat.name = "bodyFat"
        photoBodyFat.attributeType = .doubleAttributeType
        photoBodyFat.isOptional = true
        photoBodyFat.defaultValue = 0.0

        let photoMuscleMass = NSAttributeDescription()
        photoMuscleMass.name = "muscleMass"
        photoMuscleMass.attributeType = .doubleAttributeType
        photoMuscleMass.isOptional = true
        photoMuscleMass.defaultValue = 0.0

        let photoNotes = NSAttributeDescription()
        photoNotes.name = "notes"
        photoNotes.attributeType = .stringAttributeType
        photoNotes.isOptional = true

        let albumRelationship = NSRelationshipDescription()
        albumRelationship.name = "album"
        albumRelationship.destinationEntity = albumEntity
        albumRelationship.isOptional = true
        albumRelationship.maxCount = 1
        albumRelationship.deleteRule = .nullifyDeleteRule

        photoEntity.properties = [
            photoId, photoAngle, photoDate, photoImagePath,
            photoWeight, photoBodyFat, photoMuscleMass, photoNotes,
            albumRelationship
        ]

        photosRelationship.inverseRelationship = albumRelationship
        albumRelationship.inverseRelationship = photosRelationship

        model.entities = [albumEntity, photoEntity]
        return model
    }()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "SnapShift", managedObjectModel: managedObjectModel)
        let description = NSPersistentStoreDescription()
        description.type = NSSQLiteStoreType
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return container
    }()

    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    func newBackgroundContext() -> NSManagedObjectContext {
        persistentContainer.newBackgroundContext()
    }

    func save() {
        guard viewContext.hasChanges else { return }
        do {
            try viewContext.save()
        } catch {
            print("Core Data save error: \(error)")
        }
    }
}
