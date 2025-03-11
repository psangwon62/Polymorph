import ImageProcessingInterface
import UIKit
import LoggerInterface

public final class ImageProcessingServiceImpl: ImageProcessingService {
    let processor: ImageProcessing
    let logger: LoggerInterface
    
    public init(processor: ImageProcessing = ImageProcessorImpl(), logger: LoggerInterface) {
        self.processor = processor
        self.logger = logger
    }
    
    public func processImage(_ input: Data) -> [[UIColor]]? {
        guard let image = UIImage(data: input) else { return nil }
        
        logger.debug("Processing image...")
        let colors = processor.extractColors(from: image)
        logger.debug("Image Processing finished")
        return colors
    }
}
