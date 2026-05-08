import SwiftUI

struct TimelineView: View {
    let album: ProgressAlbum
    @StateObject private var viewModel = TimelineViewModel()
    @State private var showingProSheet = false

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                streakCard

                ForEach(viewModel.groupedByWeek, id: \.0) { weekLabel, photos in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(weekLabel)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)

                        ForEach(photos, id: \.id) { photo in
                            timelineCard(photo)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Timeline")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadPhotos(for: album)
        }
    }

    private var streakCard: some View {
        HStack {
            Image(systemName: "flame.fill")
                .foregroundColor(.orange)
            Text("\(viewModel.streakCount()) week streak")
                .font(.headline)
            Spacer()
            Text("\(viewModel.photos.count) photos")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func timelineCard(_ photo: ProgressPhoto) -> some View {
        HStack(spacing: 12) {
            if let image = PhotoStorageManager.shared.loadPhoto(filename: photo.imagePath) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(photo.angleEnum.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Text(photo.date ?? Date(), style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                HStack(spacing: 12) {
                    if photo.weight > 0 {
                        Label("\(photo.weight, specifier: "%.1f") lbs", systemImage: "scalemass")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    if photo.bodyFat > 0 {
                        Label("\(photo.bodyFat, specifier: "%.1f")%", systemImage: "heart")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                if let notes = photo.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .padding(8)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
    }
}
