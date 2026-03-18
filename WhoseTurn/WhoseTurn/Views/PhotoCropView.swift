import SwiftUI
import UIKit

struct CropImageData: Identifiable {
    let id = UUID()
    let data: Data
}

struct PhotoCropView: View {
    let imageData: Data
    let onCrop: (Data) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var offset: CGSize = .zero
    @GestureState private var dragOffset: CGSize = .zero

    private let cropSize: CGFloat = UIScreen.main.bounds.width * 0.8

    private var uiImage: UIImage? { UIImage(data: imageData) }

    private var currentOffset: CGSize {
        CGSize(
            width: offset.width + dragOffset.width,
            height: offset.height + dragOffset.height
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                if let uiImage {
                    let sizes = fillSizes(for: uiImage)

                    Image(uiImage: uiImage)
                        .resizable()
                        .frame(width: sizes.width, height: sizes.height)
                        .offset(currentOffset)
                        .gesture(
                            DragGesture()
                                .updating($dragOffset) { value, state, _ in
                                    state = value.translation
                                }
                                .onEnded { value in
                                    let maxX = max(0, (sizes.width - cropSize) / 2)
                                    let maxY = max(0, (sizes.height - cropSize) / 2)
                                    offset = CGSize(
                                        width: clamp(offset.width + value.translation.width, -maxX, maxX),
                                        height: clamp(offset.height + value.translation.height, -maxY, maxY)
                                    )
                                }
                        )
                }

                Rectangle()
                    .fill(Color.black.opacity(0.5))
                    .mask {
                        ZStack {
                            Rectangle()
                            Circle()
                                .frame(width: cropSize, height: cropSize)
                                .blendMode(.destinationOut)
                        }
                        .compositingGroup()
                    }
                    .allowsHitTesting(false)
                    .ignoresSafeArea()

                Circle()
                    .stroke(Color.white.opacity(0.7), lineWidth: 1)
                    .frame(width: cropSize, height: cropSize)
                    .allowsHitTesting(false)
            }
            .navigationTitle("Crop Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { cropAndSave() }
                }
            }
        }
    }

    private func fillSizes(for image: UIImage) -> CGSize {
        let aspect = image.size.width / image.size.height
        if aspect > 1 {
            return CGSize(width: cropSize * aspect, height: cropSize)
        } else {
            return CGSize(width: cropSize, height: cropSize / aspect)
        }
    }

    private func clamp(_ value: CGFloat, _ min: CGFloat, _ max: CGFloat) -> CGFloat {
        Swift.min(Swift.max(value, min), max)
    }

    private func cropAndSave() {
        guard let uiImage else {
            dismiss()
            return
        }

        let sizes = fillSizes(for: uiImage)
        let scale = uiImage.size.width / sizes.width

        let pixelOffsetX = -offset.width * scale
        let pixelOffsetY = -offset.height * scale
        let cropPixels = cropSize * scale

        let originX = (uiImage.size.width - cropPixels) / 2 + pixelOffsetX
        let originY = (uiImage.size.height - cropPixels) / 2 + pixelOffsetY
        let cropRect = CGRect(x: originX, y: originY, width: cropPixels, height: cropPixels)

        guard let cgImage = uiImage.cgImage?.cropping(to: cropRect) else {
            dismiss()
            return
        }

        let outputSize: CGFloat = 500
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: outputSize, height: outputSize), format: format)
        let final = renderer.image { _ in
            UIImage(cgImage: cgImage).draw(in: CGRect(x: 0, y: 0, width: outputSize, height: outputSize))
        }

        if let data = final.jpegData(compressionQuality: 0.85) {
            onCrop(data)
        }
        dismiss()
    }
}
