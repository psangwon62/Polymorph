import UIKit
import ImageProcessingInterface

public final class ImageProcessor: ImageProcessorInterface {
    public init() {}

    public func extractColors(from image: UIImage) -> [[UIColor]] {
        // CGImage로 변환
        guard let cgImage = image.cgImage else {
            return []
        }

        // 이미지 속성 가져오기
        let width = cgImage.width
        let height = cgImage.height
        let bitsPerComponent = cgImage.bitsPerComponent
        let bitsPerPixel = cgImage.bitsPerPixel
        let bytesPerRow = cgImage.bytesPerRow
        let colorSpace = cgImage.colorSpace ?? CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = cgImage.bitmapInfo.rawValue

        // RGBA 포맷 확인 (필요 시 조정 가능)
        let bytesPerPixel = bitsPerPixel / 8
        guard bytesPerPixel >= 3 else {
            // RGB 이상의 데이터가 없으면 빈 배열 반환 (Grayscale 등 처리 가능성 열어둠)
            return []
        }

        // CGContext 생성
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            return []
        }

        // 이미지 그리기
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        guard let pixelBuffer = context.data else {
            return []
        }

        // 픽셀 데이터에서 색상 추출
        var colors: [[UIColor]] = []
        for y in 0..<height {
            var row: [UIColor] = []
            for x in 0..<width {
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
