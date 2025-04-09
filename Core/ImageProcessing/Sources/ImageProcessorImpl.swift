import ImageProcessingInterface
import LoggerInterface
import UIKit

public final class ImageProcessorImpl: ImageProcessing {
    private var logger: LoggerInterface?

    public init(_ logger: LoggerInterface? = nil) {
        self.logger = logger
    }

    public func extractColors(from image: UIImage, downscale: DownscaleOption = .x1) async -> [[UIColor]] {
        logger?.debug("입력 BitmapInfo:", image.cgImage?.bitmapInfo.pixelFormat)
        let scaledImage = downscaleImage(image, option: downscale)
        logger?.debug("출력 BitmapInfo:", scaledImage.cgImage?.bitmapInfo.pixelFormat)
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
        let chunkSize = max(height / processorCount, 1)
        if height < processorCount {
            return convertToColors(
                pixelBuffer: pixelBuffer,
                width: width,
                startY: 0,
                endY: height,
                bytesPerRow: bytesPerRow,
                bytesPerPixel: bytesPerPixel,
                bitsPerComponent: bitsPerComponent
            )
        } else {
            let chunks = stride(from: 0, to: height, by: chunkSize).map {
                ($0, min($0 + chunkSize, height))
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
    }

    private func downscaleImage(_ image: UIImage, option: DownscaleOption) -> UIImage {
        guard option != .x1 else { return image }
        let scale = option.scaleFactor
        let newWidth = Int(image.size.width * scale)
        let newHeight = Int(image.size.height * scale)
        let newSize = CGSize(width: newWidth, height: newHeight)
        let format = image.imageRendererFormat
        // 이미지를 8bit로 강제 변환 및 렌더링
        format.preferredRange = .standard
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        return renderer.image { context in
            context.cgContext.interpolationQuality = .high
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
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
        bytesPerPixel: Int,
        bitsPerComponent _: Int
    ) -> [[UIColor]] {
        var colors: [[UIColor]] = []

        for y in startY ..< endY {
            var row: [UIColor] = []
            for x in 0 ..< width {
                let offset = y * bytesPerRow + x * bytesPerPixel
                let bRaw = CGFloat(pixelBuffer.load(fromByteOffset: offset, as: UInt8.self)) / 255
                let gRaw = CGFloat(pixelBuffer.load(fromByteOffset: offset + 1, as: UInt8.self)) / 255
                let rRaw = CGFloat(pixelBuffer.load(fromByteOffset: offset + 2, as: UInt8.self)) / 255
                let a = bytesPerPixel > 3 ? CGFloat(pixelBuffer.load(fromByteOffset: offset + 3, as: UInt8.self)) / 255 : 1.0
                let b = a > 0 ? bRaw / a : bRaw
                let g = a > 0 ? gRaw / a : gRaw
                let r = a > 0 ? rRaw / a : rRaw
                row.append(a > 0 ? UIColor(red: r, green: g, blue: b, alpha: a) : .clear)
            }
            colors.append(row)
        }
        return colors
    }
}
