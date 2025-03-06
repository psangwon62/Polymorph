import ImageProcessingInterface
import XCTest
@testable import ImageProcessing

class ImageProcessorTests: XCTestCase {
    var sut: ImageProcessor!

    override func setUp() {
        super.setUp()
        sut = ImageProcessor()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // 1. 정상적인 RGB 이미지 테스트
    func test_extractColors_withRGBImage_returnsCorrectColors() {
        // Given: 2x2 RGB 이미지 생성 (빨강, 초록, 파랑, 검정)
        let image = createTestImage(width: 2, height: 2, colors: [
            UIColor.red, UIColor.green,
            UIColor.blue, UIColor.black,
        ])

        // When
        let colors = sut.extractColors(from: image)

        // Then
        XCTAssertEqual(colors.count, 2, "Height should match")
        XCTAssertEqual(colors[0].count, 2, "Width should match")
        XCTAssertEqual(colors[0][0], UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0))
        XCTAssertEqual(colors[0][1], UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0))
        XCTAssertEqual(colors[1][0], UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0))
        XCTAssertEqual(colors[1][1], UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0))
    }

    // 2. RGBA 이미지 테스트 (알파 포함)
    func test_extractColors_withRGBAImage_returnsCorrectAlpha() {
        // Given: 1x1 투명도가 있는 이미지
        let image = createTestImage(width: 1, height: 1, colors: [
            UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.5),
        ])

        // When
        let colors = sut.extractColors(from: image)

        // Then
        XCTAssertEqual(colors.count, 1)
        XCTAssertEqual(colors[0].count, 1)
        XCTAssertEqual(colors[0][0], UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.5))
    }

    // 3. 빈 CGImage 처리 테스트
    func test_extractColors_withInvalidImage_returnsEmptyArray() {
        // Given: CGImage 없는 UIImage (실제론 드물지만 예외 처리 확인)
        let mockImage = UIImage() // 빈 이미지

        // When
        let colors = sut.extractColors(from: mockImage)

        // Then
        XCTAssertTrue(colors.isEmpty, "Should return empty array for invalid image")
    }

    // 4. Grayscale 이미지 테스트 (지원 안 함)
    func test_extractColors_withGrayscaleImage_returnsEmptyArray() {
        // Given: 1x1 Grayscale 이미지
        let image = createGrayscaleImage(width: 1, height: 1, gray: 128)

        // When
        let colors = sut.extractColors(from: image)

        // Then
        XCTAssertTrue(colors.isEmpty, "Should return empty for non-RGB/RGBA image")
    }

    // 헬퍼 함수: 테스트용 RGB/RGBA 이미지 생성
    private func createTestImage(width: Int, height: Int, colors: [UIColor]) -> UIImage {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            return UIImage()
        }

        guard let buffer = context.data else { return UIImage() }
        let pixelBuffer = buffer.bindMemory(to: UInt8.self, capacity: width * height * bytesPerPixel)

        for y in 0 ..< height {
            for x in 0 ..< width {
                let index = y * width + x
                let color = colors[index]
                var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
                color.getRed(&r, green: &g, blue: &b, alpha: &a)

                let offset = (y * bytesPerRow) + (x * bytesPerPixel)
                pixelBuffer[offset] = UInt8(r * 255)
                pixelBuffer[offset + 1] = UInt8(g * 255)
                pixelBuffer[offset + 2] = UInt8(b * 255)
                pixelBuffer[offset + 3] = UInt8(a * 255)
            }
        }

        guard let cgImage = context.makeImage() else { return UIImage() }
        return UIImage(cgImage: cgImage)
    }

    // 헬퍼 함수: Grayscale 이미지 생성
    private func createGrayscaleImage(width: Int, height: Int, gray: UInt8) -> UIImage {
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bytesPerPixel = 1
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: 0
        ) else {
            return UIImage()
        }

        guard let buffer = context.data else { return UIImage() }
        let pixelBuffer = buffer.bindMemory(to: UInt8.self, capacity: width * height * bytesPerPixel)

        for i in 0 ..< (width * height) {
            pixelBuffer[i] = gray
        }

        guard let cgImage = context.makeImage() else { return UIImage() }
        return UIImage(cgImage: cgImage)
    }
}
