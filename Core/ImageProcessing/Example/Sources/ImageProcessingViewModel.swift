import Foundation
import ImageProcessingInterface
import UIKit

class ImageProcessingViewModel: ObservableObject {
    @Published var processedImageColors: [[UIColor]] = []
    @Published var isProcessing = false

    private let processor: ImageProcessingService

    init(_ processor: ImageProcessingService) {
        self.processor = processor
    }

    public func processImageData(_ input: Data) {
        Task { @MainActor in
            isProcessing = true
            processedImageColors = []
            if let colors = await Task.detached(operation: {
                await self.processor.processImage(input)
            }).value {
                processedImageColors = colors
            }
            isProcessing = false
        }
    }
}
