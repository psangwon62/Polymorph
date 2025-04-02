import ImageProcessingInterface
import LoggerInterface
import UIKit

public final class ImageProcessorImpl: ImageProcessing {
    private var logger: LoggerInterface

    public init(_ logger: LoggerInterface) {
        self.logger = logger
    }

    public func extractColors(from image: UIImage, downscale: DownscaleOption = .x1) async -> [[UIColor]] {
        logger.debug(image.cgImage!.bitmapInfo)
        let scaledImage = downscaleImage(image, option: downscale)
        logger.debug(scaledImage.cgImage!.bitmapInfo)
        guard let cgImage = scaledImage.cgImage else { return [] }

        let width = cgImage.width
        let height = cgImage.height
        let bitsPerComponent = cgImage.bitsPerComponent
        let bitsPerPixel = cgImage.bitsPerPixel
        let bytesPerPixel = bitsPerPixel / 8
        let bytesPerRow = cgImage.bytesPerRow
        let colorSpace = cgImage.colorSpace ?? CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = cgImage.bitmapInfo.rawValue

        guard bytesPerPixel >= 3,
              let context = createContext(
                  width: width,
                  height: height,
                  bitsPerComponent: bitsPerComponent,
                  bytesPerRow: 0,
                  colorSpace: colorSpace,
                  bitmapInfo: bitmapInfo
              ),
              let pixelBuffer = renderPixelData(cgImage: cgImage, context: context, width: width, height: height)
        else { return [] }

        let processorCount = ProcessInfo.processInfo.activeProcessorCount
        let chunks = stride(from: 0, to: height, by: height / processorCount).map {
            ($0, min($0 + height / processorCount, height))
        }

        return await withTaskGroup(of: (Int, [[UIColor]]).self) { group in
            for (start, end) in chunks {
                group.addTask(priority: .userInitiated) {
                    let rows = self.convertToColors(
                        pixelBuffer: pixelBuffer,
                        width: width,
                        startY: start,
                        endY: end,
                        bytesPerRow: bytesPerRow,
                        bytesPerPixel: bytesPerPixel,
                        bitsPerComponent: bitsPerComponent
                    )
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
        let newSize = CGSize(width: newWidth, height: newHeight)

        guard let context = createContext(
            width: newWidth,
            height: newHeight,
            bitsPerComponent: cgImage.bitsPerComponent,
            bytesPerRow: 0,
            colorSpace: cgImage.colorSpace ?? CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: cgImage.bitmapInfo.rawValue
        ) else { return image }

        context.interpolationQuality = .none
        context.draw(cgImage, in: CGRect(origin: .zero, size: newSize))
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
        var adjustedBitmapInfo = bitmapInfo

        if bitsPerComponent == 16 {
            adjustedBitmapInfo &= ~CGBitmapInfo.alphaInfoMask.rawValue
            adjustedBitmapInfo |= CGImageAlphaInfo.premultipliedLast.rawValue
        }

        return CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: adjustedBitmapInfo
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
        bytesPerPixel: Int,
        bitsPerComponent: Int
    ) -> [[UIColor]] {
        var colors: [[UIColor]] = []
        let channelMax = pow(2, Double(bitsPerComponent)) - 1
        let bytesPerChannel = bitsPerComponent / 8

        for y in startY ..< endY {
            var row: [UIColor] = []
            for x in 0 ..< width {
                let offset = y * bytesPerRow + x * bytesPerPixel
                if bitsPerComponent == 16 {
                    let rRaw = CGFloat(pixelBuffer.load(fromByteOffset: offset, as: UInt16.self)) / channelMax
                    let gRaw = CGFloat(pixelBuffer.load(fromByteOffset: offset + bytesPerChannel, as: UInt16.self)) / channelMax
                    let bRaw = CGFloat(pixelBuffer.load(fromByteOffset: offset + 2 * bytesPerChannel, as: UInt16.self)) / channelMax
                    let a = bytesPerPixel > 6 ? CGFloat(pixelBuffer.load(fromByteOffset: offset + 3 * bytesPerChannel, as: UInt16.self)) / channelMax : 1.0
                    let r = a > 0 ? rRaw / a : rRaw
                    let g = a > 0 ? gRaw / a : gRaw
                    let b = a > 0 ? bRaw / a : bRaw
                    row.append(a > 0 ? UIColor(red: r, green: g, blue: b, alpha: a) : .clear)
                }
                else {
                    let r = CGFloat(pixelBuffer.load(fromByteOffset: offset, as: UInt8.self)) / channelMax
                    let g = CGFloat(pixelBuffer.load(fromByteOffset: offset + bytesPerChannel, as: UInt8.self)) / channelMax
                    let b = CGFloat(pixelBuffer.load(fromByteOffset: offset + 2 * bytesPerChannel, as: UInt8.self)) / channelMax
                    let a = bytesPerPixel > 3 ? CGFloat(pixelBuffer.load(fromByteOffset: offset + 3 * bytesPerChannel, as: UInt8.self)) / channelMax : 1.0
                    row.append(a > 0 ? UIColor(red: r, green: g, blue: b, alpha: a) : .clear)
                }
            }
            colors.append(row)
        }
        return colors
    }
}
