import PhotosUI
import SwiftUI

class PhotoPickerViewModel: ObservableObject {
    @Published private(set) var selectedImageData: Data?
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            setImage(from: imageSelection)
        }
    }

    private func setImage(from selection: PhotosPickerItem?) {
        guard let selection else {
            selectedImageData = nil
            return
        }

        Task { @MainActor in
            if let data = try? await selection.loadTransferable(type: Data.self) {
                selectedImageData = data
            }
        }
    }
}
