import ImageProcessingInterface
import UIKit

public final class ImageProcessingServiceImpl: ImageProcessingService {
    let processor: ImageProcessing
    
    public init(processor: ImageProcessing = ImageProcessorImpl()) {
        self.processor = processor
    }
    
    public func processImage(_ input: Data) -> [[UIColor]]? {
        guard let image = UIImage(data: input) else { return nil }
        
        return processor.extractColors(from: image)
    }
}
