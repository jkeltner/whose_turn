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
    @State private var scale: CGFloat = 1.0
    @GestureState private var dragOffset: CGSize = .zero
    @GestureState private var pinchScale: CGFloat = 1.0

    private let cropSize: CGFloat = UIScreen.main.bounds.width * 0.8

    private var uiImage: UIImage? { UIImage(data: imageData) }

    private var currentScale: CGFloat { scale * pinchScale }

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
                    let baseSize = fillSizes(for: uiImage)
                    let w = baseSize.width * currentScale
                    let h = baseSize.height * currentScale

                    // Dimmed full image
                    Image(uiImage: uiImage)
                        .resizable()
                        .frame(width: w, height: h)
                        .offset(currentOffset)
                        .opacity(0.4)
                        .allowsHitTesting(false)

                    // Bright image clipped to crop circle
                    ZStack {
                        Image(uiImage: uiImage)
                            .resizable()
                            .frame(width: w, height: h)
                            .offset(currentOffset)
                    }
                    .frame(width: cropSize, height: cropSize)
                    .clipShape(Circle())
                    .allowsHitTesting(false)

                    Circle()
                        .stroke(Color.white.opacity(0.7), lineWidth: 1)
                        .frame(width: cropSize, height: cropSize)
                        .allowsHitTesting(false)

                    // Gesture capture layer
                    Color.clear
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture()
                                .updating($dragOffset) { value, state, _ in
                                    state = value.translation
                                }
                                .onEnded { value in
                                    let maxX = max(0, (w - cropSize) / 2)
                                    let maxY = max(0, (h - cropSize) / 2)
                                    offset = CGSize(
                                        width: clamp(offset.width + value.translation.width, -maxX, maxX),
                                        height: clamp(offset.height + value.translation.height, -maxY, maxY)
                                    )
                                }
                        )
                        .simultaneousGesture(
                            MagnifyGesture()
                                .updating($pinchScale) { value, state, _ in
                                    state = value.magnification
                                }
                                .onEnded { value in
                                    scale = max(1.0, scale * value.magnification)
                                }
                        )
                }
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

        let baseSize = fillSizes(for: uiImage)
        let displayW = baseSize.width * scale
        let pixelsPerPoint = uiImage.size.width / displayW

        let pixelOffsetX = -offset.width * pixelsPerPoint
        let pixelOffsetY = -offset.height * pixelsPerPoint
        let cropPixels = cropSize * pixelsPerPoint

        let originX = (uiImage.size.width - cropPixels) / 2 + pixelOffsetX
        let originY = (uiImage.size.height - cropPixels) / 2 + pixelOffsetY

        let outputSize: CGFloat = 500
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: outputSize, height: outputSize), format: format)

        let final = renderer.image { _ in
            // Draw the full image positioned so the crop region maps to the output
            let drawScale = outputSize / cropPixels
            let drawX = -(originX * drawScale)
            let drawY = -(originY * drawScale)
            let drawW = uiImage.size.width * drawScale
            let drawH = uiImage.size.height * drawScale
            uiImage.draw(in: CGRect(x: drawX, y: drawY, width: drawW, height: drawH))
        }

        if let data = final.jpegData(compressionQuality: 0.85) {
            onCrop(data)
        }
        dismiss()
    }
}
