import Foundation
import SwiftUI
import Combine

@MainActor
class ComparisonViewModel: ObservableObject {
    @Published var comparisonMode: ComparisonMode = .slider
    @Published var beforePhoto: ProgressPhoto?
    @Published var afterPhoto: ProgressPhoto?
    @Published var showMetrics = true
    @Published var isProUnlocked = false

    enum ComparisonMode: String, CaseIterable {
        case slider = "Slider"
        case sideBySide = "Side by Side"
        case overlay = "Overlay"
    }

    init() {
        isProUnlocked = PurchaseManager.shared.isProUnlocked
    }

    var beforeImage: UIImage? {
        guard let photo = beforePhoto else { return nil }
        return PhotoStorageManager.shared.loadPhoto(filename: photo.imagePath)
    }

    var afterImage: UIImage? {
        guard let photo = afterPhoto else { return nil }
        return PhotoStorageManager.shared.loadPhoto(filename: photo.imagePath)
    }

    var weightDifference: Double? {
        guard let w1 = beforePhoto?.weight, w1 > 0,
              let w2 = afterPhoto?.weight, w2 > 0 else { return nil }
        return w2 - w1
    }

    var bodyFatDifference: Double? {
        guard let bf1 = beforePhoto?.bodyFat, bf1 > 0,
              let bf2 = afterPhoto?.bodyFat, bf2 > 0 else { return nil }
        return bf2 - bf1
    }

    var daysBetween: Int? {
        guard let d1 = beforePhoto?.date, let d2 = afterPhoto?.date else { return nil }
        return Calendar.current.dateComponents([.day], from: d1, to: d2).day
    }

    var canUseAdvancedMode: Bool {
        isProUnlocked || comparisonMode == .sideBySide
    }
}
