@testable import ImageProcessing
import XCTest

final class ImageProcessingTests: XCTestCase {
    private var processor: ImageProcessorImpl!

    override func setUp() {
        super.setUp()
        processor = ImageProcessorImpl()
    }

    override func tearDown() {
        processor = nil
        super.tearDown()
    }

    // MARK: - 기본 색상 추출 테스트

    func testExtractColorsFromSolidImage() async {
        // 2x2 빨간색 이미지 생성
        let image = createSolidColorImage(size: CGSize(width: 2, height: 2), color: .red)
        let colors = await processor.extractColors(from: image)

        XCTAssertEqual(colors.count, 2) // 2행
        XCTAssertEqual(colors[0].count, 2) // 2열
        for row in colors {
            for color in row {
                let (r, g, b, a) = color.rgba
                XCTAssertEqual(r, 1.0, accuracy: 0.01)
                XCTAssertEqual(g, 0.0, accuracy: 0.01)
                XCTAssertEqual(b, 0.0, accuracy: 0.01)
                XCTAssertEqual(a, 1.0, accuracy: 0.01)
            }
        }
    }

    // MARK: - 다운스케일 테스트

    func testExtractColorsWithDownscale() async {
        // 4x4 이미지 -> 2x2로 다운스케일
        let image = createSolidColorImage(size: CGSize(width: 4, height: 4), color: .blue)
        let colors = await processor.extractColors(from: image, downscale: .x4)

        // 결과 검증
        XCTAssertEqual(colors.count, 2)
        XCTAssertEqual(colors[0].count, 2)
        for row in colors {
            for color in row {
                let (r, g, b, a) = color.rgba
                XCTAssertEqual(r, 0.0, accuracy: 0.01)
                XCTAssertEqual(g, 0.0, accuracy: 0.01)
                XCTAssertEqual(b, 1.0, accuracy: 0.01)
                XCTAssertEqual(a, 1.0, accuracy: 0.01)
            }
        }
    }

    // MARK: - 방향 조정 테스트

    func testExtractColorsWithRotatedImage() async {
        // 2x2 이미지, 90도 회전
        let original = createSolidColorImage(size: CGSize(width: 2, height: 2), color: .green)
        let rotated = UIImage(cgImage: original.cgImage!, scale: 1.0, orientation: .right)

        let colors = await processor.extractColors(from: rotated)

        // 방향 조정 후 2x2 유지
        XCTAssertEqual(colors.count, 2)
        XCTAssertEqual(colors[0].count, 2)

        // 방향 조정 후
        for row in colors {
            for color in row {
                let (r, g, b, a) = color.rgba
                XCTAssertEqual(r, 0.0, accuracy: 0.01)
                XCTAssertEqual(g, 1.0, accuracy: 0.01)
                XCTAssertEqual(b, 0.0, accuracy: 0.01)
                XCTAssertEqual(a, 1.0, accuracy: 0.01)
            }
        }
    }

    // MARK: - 에러 케이스 테스트

    func testExtractColorsWithInvalidImage() async {
        // cgImage 없는 UIImage
        let image = UIImage()
        let colors = await processor.extractColors(from: image)

        // 빈 배열 반환 확인
        XCTAssertTrue(colors.isEmpty)
    }
}

// MARK: - 헬퍼 함수

private extension UIColor {
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }
}

private func createSolidColorImage(size: CGSize, color: UIColor) -> UIImage {
    let rect = CGRect(origin: .zero, size: size)
    let format = UIGraphicsImageRendererFormat()
    format.preferredRange = .standard
    format.scale = 1
    let renderer = UIGraphicsImageRenderer(size: size, format: format)
    return renderer.image { context in
        color.setFill()
        context.fill(rect)
    }
}
