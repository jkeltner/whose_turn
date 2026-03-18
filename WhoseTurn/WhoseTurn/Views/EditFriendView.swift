import SwiftUI
import PhotosUI
struct EditFriendView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var friend: Friend

    @State private var selectedPhoto: PhotosPickerItem?
    @State private var cropImageData: CropImageData?

    var body: some View {
        Form {
            Section {
                photoSection
            }

            Section {
                TextField("Friend's Name", text: $friend.name)
                    .textContentType(.name)
                    .autocorrectionDisabled()
            }

            Section {
                Button("Delete Friend", role: .destructive) {
                    modelContext.delete(friend)
                    dismiss()
                }
            }
        }
        .navigationTitle("Edit \(friend.name)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") { dismiss() }
            }
        }
        .fullScreenCover(item: $cropImageData) { item in
            PhotoCropView(imageData: item.data) { croppedData in
                friend.photoData = croppedData
            }
        }
    }

    private var photoSection: some View {
        PhotosPicker(selection: $selectedPhoto, matching: .images) {
            if let photoData = friend.photoData, let uiImage = UIImage(data: photoData) {
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
        }
        .onChange(of: selectedPhoto) { _, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    cropImageData = CropImageData(data: data)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}
