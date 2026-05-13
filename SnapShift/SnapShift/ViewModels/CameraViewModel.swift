import Foundation
import SwiftUI
import CoreData
import Combine

@MainActor
class CameraViewModel: ObservableObject {
    @Published var selectedAngle: PhotoAngle = .front {
        didSet { reloadGhostImage() }
    }
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
    private var timerTask: Task<Void, Never>?
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
        timerTask?.cancel()
        countdown = seconds
        isTimerActive = true
        timerTask = Task { @MainActor in
            for remaining in (1...seconds).reversed() {
                guard !Task.isCancelled else { return }
                countdown = remaining
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
            guard !Task.isCancelled else { return }
            countdown = nil
            isTimerActive = false
            capturePhoto()
        }
    }

    func cancelTimer() {
        timerTask?.cancel()
        timerTask = nil
        countdown = nil
        isTimerActive = false
    }

    func toggleVoiceCapture() {
        if voiceCaptureManager.isListening {
            voiceCaptureManager.stopListening()
        } else {
            voiceCaptureManager.startListening()
        }
    }

    private func loadGhostImage(from album: ProgressAlbum) {
        reloadGhostImage()
    }

    private func reloadGhostImage() {
        guard let album = currentAlbum else { return }
        let anglePhotos = album.photoArray.filter { $0.angle == selectedAngle.rawValue }
        ghostImage = anglePhotos.last.flatMap { PhotoStorageManager.shared.loadPhoto(filename: $0.imagePath) }
    }
}
