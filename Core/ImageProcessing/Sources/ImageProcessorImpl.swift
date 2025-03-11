import ImageProcessingInterface
import UIKit

public final class ImageProcessorImpl: ImageProcessing {
    public init() {}
    
    private func cgImage(from image: UIImage) -> CGImage? {
        return image.cgImage
    }

    public func extractColors(from image: UIImage) -> [[UIColor]] {
        guard let cgImage = image.cgImage else { return [] }

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

        return convertToColors(pixelBuffer: pixelBuffer, width: width, height: height, bytesPerRow: bytesPerRow, bytesPerPixel: bytesPerPixel)
    }

    private func createContext(width: Int, height: Int, bitsPerComponent: Int, bytesPerRow: Int, colorSpace: CGColorSpace, bitmapInfo: UInt32) -> CGContext? {
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

    private func renderPixelData(cgImage: CGImage, context: CGContext, width: Int, height: Int) -> UnsafeMutableRawPointer? {
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        return context.data
    }

    private func convertToColors(pixelBuffer: UnsafeMutableRawPointer, width: Int, height: Int, bytesPerRow: Int, bytesPerPixel: Int) -> [[UIColor]] {
        var colors: [[UIColor]] = []
        for y in 0 ..< height {
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
