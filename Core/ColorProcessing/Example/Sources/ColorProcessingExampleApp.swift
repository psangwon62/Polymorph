import ColorProcessing
import Logger
import SwiftUI

@main
struct ColorProcessingExampleApp: App {
    @StateObject private var viewModel = ContentViewModel(comparator: ColorProcessingFactory(logger: LoggerService()).createComparator())
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }
    }
}
