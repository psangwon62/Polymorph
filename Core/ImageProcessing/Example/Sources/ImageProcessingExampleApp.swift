import ImageProcessing
import SwiftUI

@main
struct ImageProcessingExampleApp: App {
    @StateObject var photoPickerVM = PhotoPickerViewModel()
    @StateObject var imageProcessingVM = ImageProcessingViewModel(ImageProcessingServiceImpl())

    var body: some Scene {
        WindowGroup {
            ContentView(
                photoPickerVM: photoPickerVM,
                imageProcessingVM: imageProcessingVM
            )
        }
    }
}
