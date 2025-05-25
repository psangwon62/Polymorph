@testable import ColorProcessing
@testable import ColorProcessingInterface
@testable import ColorProcessingTesting
@testable import LoggerTesting
import XCTest

final class ColorProcessingFactoryTests: XCTestCase {
    private var factory: ColorProcessingFactory!
    private var mockComparatorCache: MockCache<UIColor, UIColor>!
    private var mockConverterCache: MockCache<UIColor, CIELAB>!
    private var mockLogger: MockLogger!

    override func setUp() {
        super.setUp()
        mockLogger = MockLogger()
        mockComparatorCache = MockCache()
        mockConverterCache = MockCache()
        factory = DefaultColorProcessingFactory(logger: mockLogger)
    }

    override func tearDown() {
        factory = nil
        mockLogger = nil
        super.tearDown()
    }

    func testCreateLUT() {
        let expectedType = GRC64LUT.self
        let lut = factory.createLUT()

        XCTAssertTrue(lut is GRC64LUT, "LUT should be \(expectedType)")
        XCTAssertEqual(lut.getAll().count, 64, "GRC64LUT should have 64 colors")
        XCTAssertTrue(mockLogger.containsMessage("ColorLUT initialized with 64 GRC64 entries"), "Logger should log LUT initialization")
    }

    func testCreateCache() {
        let expectedType = GenericCache<UIColor, CIELAB>.self
        let cache: any Cache<UIColor, CIELAB> = factory.createCache()

        XCTAssertTrue(cache is GenericCache<UIColor, CIELAB>, "Cache should be GenericCache")
        XCTAssertTrue(mockLogger.containsMessage(.initialized("\(expectedType), MaxSize:1000")), "Initialization logged")
    }

    func testCreateConverter_DefaultCache() {
        let expectedConverterType = DefaultColorConverter.self
        let expectedCacheType = GenericCache<UIColor, CIELAB>.self
        let converter = factory.createConverter(cache: nil)

        XCTAssertTrue(converter is DefaultColorConverter, "Converter should be \(expectedConverterType)")
        XCTAssertTrue(mockLogger.containsMessage("Default Color Converter initialized"), "Logger should log converter initialization")
        XCTAssertTrue(mockLogger.containsMessage(.initialized("\(expectedCacheType), MaxSize:1000")), "Initialization logged")
    }

    func testCreateConverter_CustomCache() async {
        let expectedConverterType = DefaultColorConverter.self
        let expectedCacheType = GenericCache<UIColor, CIELAB>.self
        let converter = factory.createConverter(cache: mockConverterCache)

        XCTAssertTrue(converter is DefaultColorConverter, "Converter should be \(expectedConverterType)")
        XCTAssertTrue(mockLogger.containsMessage("Default Color Converter initialized"), "Logger should log converter initialization")
        XCTAssertFalse(mockLogger.containsMessage(.initialized("\(expectedCacheType), MaxSize:1000")), "Default cache should not be used")
    }

    func testCreateComparator_DefaultCache() {
        let expectedComparatorType = DefaultColorComparator.self
        let expectedCacheType = GenericCache<UIColor, UIColor>.self
        let comparator = factory.createComparator(cache: nil)

        XCTAssertTrue(comparator is DefaultColorComparator, "Comparator should be \(expectedComparatorType)")
        XCTAssertTrue(mockLogger.containsMessage("Default Color Comparator initialized"), "Logger should log comparator initialization")
        XCTAssertTrue(mockLogger.containsMessage(.initialized("\(expectedCacheType), MaxSize:1000")), "Initialization logged")
    }

    func testCreateComparator_CustomCache() async {
        let expectedComparatorType = DefaultColorComparator.self
        let expectedCacheType = GenericCache<UIColor, UIColor>.self
        let comparator = factory.createComparator(cache: mockComparatorCache)

        XCTAssertTrue(comparator is DefaultColorComparator, "Comparator should be \(expectedComparatorType)")
        XCTAssertTrue(mockLogger.containsMessage("Default Color Comparator initialized"), "Logger should log comparator initialization")
        XCTAssertFalse(mockLogger.containsMessage(.initialized("\(expectedCacheType), MaxSize:1000")), "Default cache should not be used")
    }

    func testLoggerPropagation() async {
        let _ = factory.createLUT()
        let _ = factory.createConverter(cache: nil)
        let _ = factory.createComparator(cache: mockComparatorCache)
        let expectedConverterCacheType = GenericCache<UIColor, CIELAB>.self
        let expectedComparatorCacheType = GenericCache<UIColor, UIColor>.self

        XCTAssertTrue(mockLogger.containsMessage("ColorLUT initialized with 64 GRC64 entries"), "LUT should log")
        XCTAssertTrue(mockLogger.containsMessage("Default Color Converter initialized"), "Converter should log")
        XCTAssertTrue(mockLogger.containsMessage("Default Color Comparator initialized"), "Comparator should log")
        XCTAssertTrue(mockLogger.containsMessage(.initialized("\(expectedConverterCacheType), MaxSize:1000")), "Converter cache should log")
        XCTAssertFalse(mockLogger.containsMessage(.initialized("\(expectedComparatorCacheType), MaxSize:1000")), "Comparator custom cache should not log GenericCache")
    }
}
