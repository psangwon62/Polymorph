import ColorProcessing
import Logger
import SwiftUI

@main
struct ColorProcessingExampleApp: App {
    @StateObject private var viewModel = ContentViewModel(comparator: DefaultColorProcessingFactory(logger: LoggerService()).createComparator())
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }
    }
}
