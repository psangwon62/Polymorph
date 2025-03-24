import ImageProcessingInterface
import UIKit

public final class ImageProcessorImpl: ImageProcessing {
    public init() {}

    private func cgImage(from image: UIImage) -> CGImage? {
        return image.cgImage
    }

    public func extractColors(from image: UIImage, downscale: DownscaleOption = .x1) async -> [[UIColor]] {
        let scaledImage = downscaleImage(image, option: downscale)
        guard let cgImage = scaledImage.cgImage else { return [] }

        let width = cgImage.width
        let height = cgImage.height
        let bitsPerComponent = cgImage.bitsPerComponent
        let bitsPerPixel = cgImage.bitsPerPixel
        let bytesPerRow = cgImage.bytesPerRow
        let colorSpace = cgImage.colorSpace ?? CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = cgImage.bitmapInfo.rawValue
        let bytesPerPixel = bitsPerPixel / 8

        guard bytesPerPixel >= 3,
              let context = createContext(width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, colorSpace: colorSpace, bitmapInfo: bitmapInfo),
              let pixelBuffer = renderPixelData(cgImage: cgImage, context: context, width: width, height: height)
        else { return [] }

        let processorCount = ProcessInfo.processInfo.activeProcessorCount
        let chunks = stride(from: 0, to: height, by: height / processorCount).map {
            ($0, min($0 + height / processorCount, height))
        }

        return await withTaskGroup(of: (Int, [[UIColor]]).self) { group in
            for (start, end) in chunks {
                group.addTask(priority: .userInitiated) {
                    let rows = self.convertToColors(pixelBuffer: pixelBuffer, width: width, startY: start, endY: end, bytesPerRow: bytesPerRow, bytesPerPixel: bytesPerPixel)
                    return (start, rows)
                }
            }
            var sortedResults: [(Int, [[UIColor]])] = []
            for await result in group {
                sortedResults.append(result)
            }
            return sortedResults.sorted { $0.0 < $1.0 }.flatMap { $0.1 }
        }
    }

    private func downscaleImage(_ image: UIImage, option: DownscaleOption) -> UIImage {
        guard option != .x1, let cgImage = image.cgImage else { return image }

        let scale = option.scaleFactor
        let newWidth = Int(image.size.width * scale)
        let newHeight = Int(image.size.height * scale)

        guard let context = CGContext(
            data: nil,
            width: newWidth,
            height: newHeight,
            bitsPerComponent: cgImage.bitsPerComponent,
            bytesPerRow: 0,
            space: cgImage.colorSpace ?? CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: cgImage.bitmapInfo.rawValue
        ) else { return image }

        context.interpolationQuality = .none
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        return UIImage(cgImage: context.makeImage() ?? cgImage)
    }

    private func createContext(
        width: Int,
        height: Int,
        bitsPerComponent: Int,
        bytesPerRow: Int,
        colorSpace: CGColorSpace,
        bitmapInfo: UInt32
    ) -> CGContext? {
        return CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        )
    }

    private func renderPixelData(
        cgImage: CGImage,
        context: CGContext,
        width: Int,
        height: Int
    ) -> UnsafeMutableRawPointer? {
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        return context.data
    }

    private func convertToColors(
        pixelBuffer: UnsafeMutableRawPointer,
        width: Int,
        startY: Int,
        endY: Int,
        bytesPerRow: Int,
        bytesPerPixel: Int
    ) -> [[UIColor]] {
        var colors: [[UIColor]] = []
        for y in startY ..< endY {
            var row: [UIColor] = []
            for x in 0 ..< width {
                let offset = y * bytesPerRow + x * bytesPerPixel
                let r = CGFloat(pixelBuffer.load(fromByteOffset: offset, as: UInt8.self)) / 255.0
                let g = CGFloat(pixelBuffer.load(fromByteOffset: offset + 1, as: UInt8.self)) / 255.0
                let b = CGFloat(pixelBuffer.load(fromByteOffset: offset + 2, as: UInt8.self)) / 255.0
                let a = bytesPerPixel > 3 ? CGFloat(pixelBuffer.load(fromByteOffset: offset + 3, as: UInt8.self)) / 255.0 : 1.0
                row.append(UIColor(red: r, green: g, blue: b, alpha: a))
            }
            colors.append(row)
        }
        return colors
    }
}
