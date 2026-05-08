import Foundation
import SwiftUI
import CoreData
import Combine

@MainActor
class CameraViewModel: ObservableObject {
    @Published var selectedAngle: PhotoAngle = .front
    @Published var ghostImage: UIImage?
    @Published var ghostOpacity: Double = 0.3
    @Published var showGrid = false
    @Published var countdown: Int?
    @Published var isTimerActive = false
    @Published var weight: Double?
    @Published var bodyFat: Double?
    @Published var isProUnlocked = false

    let cameraManager = CameraManager()
    let voiceCaptureManager = VoiceCaptureManager()

    private var currentAlbum: ProgressAlbum?
    private let context = CoreDataStack.shared.viewContext

    init() {
        isProUnlocked = PurchaseManager.shared.isProUnlocked
        voiceCaptureManager.onTrigger = { [weak self] in
            self?.capturePhoto()
        }
    }

    func setAlbum(_ album: ProgressAlbum) {
        currentAlbum = album
        loadGhostImage(from: album)
    }

    func capturePhoto() {
        cameraManager.capturePhoto()
    }

    func handleCapturedImage(_ image: UIImage) {
        guard let album = currentAlbum else { return }

        let photo = ProgressPhoto(context: context)
        photo.id = UUID()
        photo.date = Date()
        photo.angle = selectedAngle.rawValue
        photo.weight = weight ?? 0
        photo.bodyFat = bodyFat ?? 0
        photo.album = album

        if let path = PhotoStorageManager.shared.savePhoto(image, for: photo.id!) {
            photo.imagePath = path
        }

        CoreDataStack.shared.save()
        ghostImage = image
    }

    func startTimer(seconds: Int = 5) {
        countdown = seconds
        isTimerActive = true
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            Task { @MainActor [weak self] in
                guard let self = self else { timer.invalidate(); return }
                self.countdown! -= 1
                if self.countdown! <= 0 {
                    timer.invalidate()
                    self.countdown = nil
                    self.isTimerActive = false
                    self.capturePhoto()
                }
            }
        }
    }

    func toggleVoiceCapture() {
        if voiceCaptureManager.isListening {
            voiceCaptureManager.stopListening()
        } else {
            voiceCaptureManager.startListening()
        }
    }

    private func loadGhostImage(from album: ProgressAlbum) {
        let anglePhotos = album.photoArray.filter { $0.angle == selectedAngle.rawValue }
        if let lastPhoto = anglePhotos.last {
            ghostImage = PhotoStorageManager.shared.loadPhoto(filename: lastPhoto.imagePath)
        }
    }
}
