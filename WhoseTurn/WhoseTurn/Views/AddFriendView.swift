import SwiftUI
import PhotosUI
import SwiftData

struct AddFriendView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoData: Data?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    photoSection
                }

                Section {
                    TextField("Friend's Name", text: $name)
                        .textContentType(.name)
                        .autocorrectionDisabled()
                }
            }
            .navigationTitle("Add Friend")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).count < 2)
                }
            }
        }
    }

    private var photoSection: some View {
        VStack {
            if let photoData, let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundStyle(.gray.opacity(0.3))
            }

            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                Text("Choose Photo")
            }
            .onChange(of: selectedPhoto) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        photoData = data
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func save() {
        let friend = Friend(name: name.trimmingCharacters(in: .whitespaces), photoData: photoData)
        modelContext.insert(friend)
        dismiss()
    }
}
