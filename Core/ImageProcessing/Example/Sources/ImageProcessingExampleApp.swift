import ImageProcessing
import SwiftUI
import Logger

@main
struct ImageProcessingExampleApp: App {
    @StateObject var photoPickerVM = PhotoPickerViewModel()
    @StateObject var imageProcessingVM = ImageProcessingViewModel(ImageProcessingServiceImpl(logger: LoggerService()))

    var body: some Scene {
        WindowGroup {
            ContentView(
                photoPickerVM: photoPickerVM,
                imageProcessingVM: imageProcessingVM
            )
        }
    }
}
