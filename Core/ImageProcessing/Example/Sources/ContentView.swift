import ImageProcessingInterface
import PhotosUI
import SwiftUI

struct ContentView: View {
    @ObservedObject private var photoPickerVM: PhotoPickerViewModel
    @ObservedObject private var imageProcessingVM: ImageProcessingViewModel

    init(photoPickerVM: PhotoPickerViewModel, imageProcessingVM: ImageProcessingViewModel) {
        self.photoPickerVM = photoPickerVM
        self.imageProcessingVM = imageProcessingVM
    }

    var body: some View {
        VStack(spacing: 20) {
            if let uiImageData = photoPickerVM.selectedImageData,
               let uiImage = UIImage(data: uiImageData)
            {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
            } else {
                Text("사진을 선택하세요")
                    .font(.headline)
                    .foregroundColor(.gray)
            }

            PhotosPicker(selection: $photoPickerVM.imageSelection, matching: .images) {
                Text("사진 선택")
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            let colors = imageProcessingVM.processedImageColors

            Button(action: {
                if let data = photoPickerVM.selectedImageData {
                    imageProcessingVM.processImageData(data)
                }
            }) {
                if imageProcessingVM.isProcessing {
                    ProgressView()
                } else {
                    Text("색상 추출")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(colors.isEmpty ? Color.gray : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .disabled(photoPickerVM.selectedImageData == nil || imageProcessingVM.isProcessing)

            if !colors.isEmpty {
                ScrollView(.vertical) {
                    Canvas { context, _ in
                        let pixelSize: CGFloat = 1
                        for row in 0 ..< colors.count {
                            for col in 0 ..< colors[row].count {
                                let rect = CGRect(x: CGFloat(col) * pixelSize, y: CGFloat(row) * pixelSize, width: pixelSize, height: pixelSize)
                                context.fill(Path(rect), with: .color(Color(colors[row][col])))
                            }
                        }
                    }
                    .frame(width: CGFloat(colors[0].count) * 1, height: CGFloat(colors.count) * 1)
                    Text("크기: \(colors.count) x \(colors.first?.count ?? 0) 픽셀")
                        .font(.subheadline)
                        .padding(.top, 10)
                }
            }
        }
        .padding()
    }
}
