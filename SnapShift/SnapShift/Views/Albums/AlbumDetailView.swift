import SwiftUI

struct AlbumDetailView: View {
    let album: ProgressAlbum
    @StateObject private var timelineVM = TimelineViewModel()
    @State private var showingCamera = false
    @State private var showingComparison = false
    @State private var selectedPhotos: [ProgressPhoto] = []
    @State private var showingProSheet = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if timelineVM.groupedByWeek.isEmpty {
                    emptyPhotosState
                } else {
                    ForEach(timelineVM.groupedByWeek, id: \.0) { weekLabel, photos in
                        weekSection(weekLabel: weekLabel, photos: photos)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(album.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingCamera = true
                } label: {
                    Image(systemName: "camera")
                }
            }
        }
        .fullScreenCover(isPresented: $showingCamera) {
            GhostOverlayCameraView(album: album)
        }
        .sheet(isPresented: $showingComparison) {
            if selectedPhotos.count == 2 {
                ComparisonView(beforePhoto: selectedPhotos[0], afterPhoto: selectedPhotos[1])
            }
        }
        .sheet(isPresented: $showingProSheet) {
            ProUpgradeSheet()
        }
        .onAppear {
            timelineVM.loadPhotos(for: album)
        }
    }

    private var emptyPhotosState: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No Photos Yet")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Take your first progress photo to get started")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Button("Take Photo") {
                showingCamera = true
            }
            .buttonStyle(.borderedProminent)
            .tint(.teal)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }

    private func weekSection(weekLabel: String, photos: [ProgressPhoto]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(weekLabel)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(photos, id: \.id) { photo in
                    photoGridItem(photo)
                }
            }
        }
    }

    private func photoGridItem(_ photo: ProgressPhoto) -> some View {
        Group {
            if let image = PhotoStorageManager.shared.loadPhoto(filename: photo.imagePath) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(minHeight: 120)
                    .clipped()
                    .cornerRadius(8)
                    .onTapGesture {
                        if selectedPhotos.count < 2 {
                            selectedPhotos.append(photo)
                            if selectedPhotos.count == 2 {
                                showingComparison = true
                            }
                        }
                    }
                    .overlay {
                        if selectedPhotos.contains(where: { $0.id == photo.id }) {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.teal, lineWidth: 3)
                        }

                        VStack {
                            HStack {
                                Spacer()
                                Text(photo.angleEnum.displayName)
                                    .font(.caption2)
                                    .padding(3)
                                    .background(Color.black.opacity(0.6))
                                    .foregroundColor(.white)
                                    .cornerRadius(4)
                            }
                            Spacer()
                        }
                        .padding(4)
                    }
            }
        }
    }
}
