@testable import ColorProcessing
@testable import ColorProcessingInterface
@testable import ColorProcessingTesting
import LoggerTesting
import XCTest

private final class GenericCacheTests: XCTestCase {
    private var cache: GenericCache<UIColor, CIELAB>!
    private var mockLogger: MockLogger!
    private var mockConverter: MockColorConverter!

    override func setUp() async throws {
        mockLogger = MockLogger()
        mockConverter = MockColorConverter()
        cache = GenericCache(maxCacheSize: 3, logger: mockLogger)
    }

    override func tearDown() async throws {
        cache = nil
        mockLogger = nil
        mockConverter = nil
    }

    func testInitialization() async {
        let all = await cache.getAll()
        XCTAssertEqual(all.count, 0, "Cache should be empty")
        XCTAssertTrue(mockLogger.containsMessage("GenericCache<UIColor, CIELAB> initialized with max size: 3"), "Initialization logged")
    }

    func testSetAndGet() async {
        let key = UIColor.red
        let value = await cache.get(for: key) { _ in CIELAB(L: 50, a: 20, b: 10) }
        XCTAssertEqual(value, CIELAB(L: 50, a: 20, b: 10), "Should return computed value")
        let cachedValue = await cache.get(for: key) { _ in CIELAB(L: 0, a: 0, b: 0) }
        XCTAssertEqual(cachedValue, CIELAB(L: 50, a: 20, b: 10), "Should return cached value")
        XCTAssertTrue(mockLogger.containsMessage("Cache miss for key: \(key)"), "Miss logged")
        XCTAssertTrue(mockLogger.containsMessage("Cache hit for key: \(key)"), "Hit logged")
    }

    func testClear() async {
        await cache.get(for: UIColor.red) { _ in CIELAB(L: 50, a: 20, b: 10) }
        await cache.clear()
        let value = await cache.get(for: UIColor.red) { _ in CIELAB(L: 100, a: 0, b: 0) }
        XCTAssertEqual(value, CIELAB(L: 100, a: 0, b: 0), "Should compute new value after clear")
        XCTAssertTrue(mockLogger.containsMessage("GenericCache cleared"), "Clear logged")
    }

    func testLRUEviction() async {
        await cache.get(for: UIColor.red) { _ in CIELAB(L: 1, a: 0, b: 0) }
        await cache.get(for: UIColor.blue) { _ in CIELAB(L: 2, a: 0, b: 0) }
        await cache.get(for: UIColor.green) { _ in CIELAB(L: 3, a: 0, b: 0) }
        await cache.get(for: UIColor.black) { _ in CIELAB(L: 4, a: 0, b: 0) }
        let value = await cache.get(for: UIColor.red) { _ in CIELAB(L: 5, a: 0, b: 0) }
        XCTAssertEqual(value, CIELAB(L: 5, a: 0, b: 0), "Red should be evicted and recomputed")
        XCTAssertTrue(mockLogger.containsMessage("Cache full, removing oldest: \(UIColor.red)"), "Eviction logged")
    }

    func testThreadSafety() async {
        let keys = [UIColor.red, UIColor.blue, UIColor.green]
        await withTaskGroup(of: Void.self) { group in
            for i in 0 ..< 100 {
                group.addTask {
                    let key = keys[i % keys.count]
                    let value = await self.cache.get(for: key) { _ in CIELAB(L: CGFloat(i), a: 0, b: 0) }
                    XCTAssertNotNil(value, "Value for \(key)")
                }
            }
        }
        let all = await cache.getAll()
        XCTAssertLessThanOrEqual(all.count, 3, "Cache should respect maxCacheSize")
    }
}
