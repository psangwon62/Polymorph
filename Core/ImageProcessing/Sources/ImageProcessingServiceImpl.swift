import ImageProcessingInterface
import LoggerInterface
import UIKit

public final class ImageProcessingServiceImpl: ImageProcessingService {
    let processor: ImageProcessing
    let logger: LoggerInterface

    public init(processor: ImageProcessing = ImageProcessorImpl(), logger: LoggerInterface) {
        self.processor = processor
        self.logger = logger
    }

    public func processImage(_ input: Data) async -> [[UIColor]]? {
        guard let image = UIImage(data: input) else { return nil }

        logger.debug("Processing image...")
        let colors = await processor.extractColors(from: image, downscale: .x64)
        logger.debug("Image Processing finished")
        
        return colors
    }
}
