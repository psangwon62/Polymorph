import ColorProcessing
import ColorProcessingInterface
@testable import LoggerTesting
import XCTest

class GenericCacheTests: XCTestCase {
    var cache: GenericCache<UIColor, CIELAB>!
    var mockLogger: MockLogger!

    override func setUp() {
        super.setUp()
        mockLogger = MockLogger()
        cache = GenericCache(maxCacheSize: 3, logger: mockLogger)
    }

    override func tearDown() {
        cache = nil
        mockLogger = nil
        super.tearDown()
    }

    func testInitialization() {
        XCTAssertEqual(cache.maxCacheSize, 3, "최대 캐시 크기 설정")
        XCTAssertTrue(mockLogger.debugMessages.contains { $0.contains("GenericCache initialized with max size: 3") }, "초기화 로깅")
    }

    func testCacheHit() {
        let color = UIColor.red
        let lab = CIELAB(L: 50, a: 20, b: 10)
        cache.store(key: color, value: lab)
        let result = cache.get(for: color) { _ in CIELAB(L: 0, a: 0, b: 0) }
        XCTAssertEqual(result, lab, "캐시 히트로 저장된 값 반환")
        XCTAssertTrue(mockLogger.debugMessages.contains { $0.contains("Cache hit for key: \(color)") }, "캐시 히트 로깅")
    }

    func testCacheMiss() {
        let color = UIColor.red
        let lab = CIELAB(L: 50, a: 20, b: 10)
        let result = cache.get(for: color) { _ in lab }
        XCTAssertEqual(result, lab, "캐시 미스로 compute 값 반환")
        XCTAssertTrue(mockLogger.debugMessages.contains { $0.contains("Cache miss for key: \(color)") }, "캐시 미스 로깅")
        XCTAssertEqual(cache.get(for: color) { _ in CIELAB(L: 0, a: 0, b: 0) }, lab, "캐시에 저장됨")
    }

    func testLRUEviction() {
        let colors = [UIColor.red, UIColor.green, UIColor.blue, UIColor.black]
        let labs = (0 ..< 4).map { CIELAB(L: CGFloat($0 * 10), a: 0, b: 0) }
        for (color, lab) in zip(colors[0 ... 2], labs) {
            cache.store(key: color, value: lab)
        }
        cache.store(key: colors[3], value: labs[3])
        let result = cache.get(for: colors[0]) { _ in CIELAB(L: 100, a: 0, b: 0) }
        XCTAssertEqual(result, CIELAB(L: 100, a: 0, b: 0), "가장 오래된 키 제거")
        XCTAssertTrue(mockLogger.debugMessages.contains { $0.contains("Cache full, removing oldest: \(colors[0])") }, "LRU 제거 로깅")
    }

    func testUpdateAccessOrder() {
        let color1 = UIColor.red
        let color2 = UIColor.green
        let lab = CIELAB(L: 50, a: 20, b: 10)
        cache.store(key: color1, value: lab)
        cache.store(key: color2, value: lab)
        cache.get(for: color1) { _ in CIELAB(L: 0, a: 0, b: 0) }
        cache.store(key: UIColor.blue, value: lab)
        let result = cache.get(for: color2) { _ in CIELAB(L: 100, a: 0, b: 0) }
        XCTAssertEqual(result, CIELAB(L: 100, a: 0, b: 0), "color2가 LRU로 제거")
        XCTAssertTrue(mockLogger.debugMessages.contains { $0.contains("Updated access order for key: \(color1)") }, "접근 순서 업데이트 로깅")
    }

    func testClear() {
        let color = UIColor.red
        let lab = CIELAB(L: 50, a: 20, b: 10)
        cache.store(key: color, value: lab)
        cache.clear()
        let result = cache.get(for: color) { _ in CIELAB(L: 0, a: 0, b: 0) }
        XCTAssertEqual(result, CIELAB(L: 0, a: 0, b: 0), "캐시 비워짐")
        XCTAssertTrue(mockLogger.debugMessages.contains { $0.contains("GenericCache cleared") }, "캐시 클리어 로깅")
    }

    func testThreadSafety() {
        let cache = GenericCache<UIColor, CIELAB>(maxCacheSize: 100, logger: mockLogger)
        let queue = DispatchQueue.global()
        let group = DispatchGroup()
        let color = UIColor.red
        let lab = CIELAB(L: 50, a: 20, b: 10)
        for _ in 0 ..< 100 {
            group.enter()
            queue.async {
                cache.store(key: color, value: lab)
                _ = cache.get(for: color) { _ in CIELAB(L: 0, a: 0, b: 0) }
                group.leave()
            }
        }
        group.wait()
        let result = cache.get(for: color) { _ in CIELAB(L: 0, a: 0, b: 0) }
        XCTAssertEqual(result, lab, "스레드 안전성 보장")
    }
}
