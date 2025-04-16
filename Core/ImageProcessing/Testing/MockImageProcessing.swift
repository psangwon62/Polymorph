import Foundation
import ImageProcessingInterface
import UIKit

public struct MockImageProcessing: ImageProcessing {
    public func extractColors(from _: UIImage, downscale _: ImageProcessingInterface.DownscaleOption) async -> [[UIColor]] {
        return [[]]
    }
}
