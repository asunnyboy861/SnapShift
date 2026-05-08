import SwiftUI

struct CreateAlbumView: View {
    @State private var albumName = ""
    @Environment(\.dismiss) private var dismiss
    let onCreate: (String) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Album Name", text: $albumName)
                } header: {
                    Text("Name your progress album")
                }
            }
            .navigationTitle("New Album")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        if !albumName.trimmingCharacters(in: .whitespaces).isEmpty {
                            onCreate(albumName.trimmingCharacters(in: .whitespaces))
                            dismiss()
                        }
                    }
                    .disabled(albumName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
