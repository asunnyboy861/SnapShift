import SwiftUI

struct AlbumListView: View {
    @StateObject private var viewModel = AlbumListViewModel()
    @State private var showingCreateAlbum = false
    @State private var showingProSheet = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.albums.isEmpty {
                    emptyState
                } else {
                    albumList
                }
            }
            .navigationTitle("SnapShift")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if viewModel.canCreateAlbum() {
                            showingCreateAlbum = true
                        } else {
                            showingProSheet = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreateAlbum) {
                CreateAlbumView { name in
                    viewModel.createAlbum(name: name)
                }
            }
            .sheet(isPresented: $showingProSheet) {
                ProUpgradeSheet()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No Albums Yet")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Create your first album to start tracking your progress")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button("Create Album") {
                showingCreateAlbum = true
            }
            .buttonStyle(.borderedProminent)
            .tint(.teal)
        }
    }

    private var albumList: some View {
        List {
            ForEach(viewModel.albums, id: \.id) { album in
                NavigationLink {
                    AlbumDetailView(album: album)
                } label: {
                    AlbumRow(album: album, viewModel: viewModel)
                }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    viewModel.deleteAlbum(viewModel.albums[index])
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

struct AlbumRow: View {
    let album: ProgressAlbum
    @ObservedObject var viewModel: AlbumListViewModel

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray5))
                    .frame(width: 56, height: 56)

                if let lastPhoto = album.latestPhoto,
                   let thumb = PhotoStorageManager.shared.thumbnail(filename: lastPhoto.imagePath, size: CGSize(width: 56, height: 56)) {
                    Image(uiImage: thumb)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 56, height: 56)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    Image(systemName: "camera")
                        .foregroundColor(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(album.name ?? "")
                    .font(.headline)
                Text("\(album.photoCount) photos · \(album.weekSpan) weeks")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if !viewModel.canAddPhoto(to: album) {
                Image(systemName: "lock.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
