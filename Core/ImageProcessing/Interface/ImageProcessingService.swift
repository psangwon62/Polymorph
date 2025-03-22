import UIKit

public protocol ImageProcessingService {
    func processImage(_ input: Data) async -> [[UIColor]]?
}
