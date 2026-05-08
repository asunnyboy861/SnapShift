import Foundation
import CoreData
import Combine

@MainActor
class TimelineViewModel: ObservableObject {
    @Published var photos: [ProgressPhoto] = []
    @Published var groupedByWeek: [(String, [ProgressPhoto])] = []

    private let context = CoreDataStack.shared.viewContext

    func loadPhotos(for album: ProgressAlbum) {
        photos = album.photoArray
        groupByWeek()
    }

    private func groupByWeek() {
        let calendar = Calendar.current
        var groups: [String: [ProgressPhoto]] = [:]

        for photo in photos {
            guard let date = photo.date else { continue }
            let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
            guard let weekStart = calendar.date(from: components) else { continue }
            let key = formatDate(weekStart)
            groups[key, default: []].append(photo)
        }

        groupedByWeek = groups.sorted { $0.key > $1.key }.map { ($0.key, $0.value.sorted { $0.date ?? Date() < $1.date ?? Date() }) }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }

    func photosForDate(_ date: Date) -> [ProgressPhoto] {
        let calendar = Calendar.current
        return photos.filter {
            guard let photoDate = $0.date else { return false }
            return calendar.isDate(photoDate, inSameDayAs: date)
        }
    }

    func streakCount() -> Int {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = Date()

        let photoDates = Set(photos.compactMap { photo -> Date? in
            guard let date = photo.date else { return nil }
            return calendar.startOfDay(for: date)
        })

        while photoDates.contains(calendar.startOfDay(for: checkDate)) {
            streak += 1
            checkDate = calendar.date(byAdding: .day, value: -7, to: checkDate) ?? checkDate
        }

        return streak
    }
}
