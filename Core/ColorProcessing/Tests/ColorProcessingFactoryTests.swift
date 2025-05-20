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
        XCTAssertTrue(mockLogger.debugMessages.contains { $0.contains("ColorLUT initialized with 64 GRC64 entries") }, "Logger should log LUT initialization")
    }

    func testCreateCache() {
        let expectedType = GenericCache<UIColor, CIELAB>.self
        let cache: any Cache<UIColor, CIELAB> = factory.createCache()

        XCTAssertTrue(cache is GenericCache<UIColor, CIELAB>, "Cache should be GenericCache")
        XCTAssertTrue(mockLogger.debugMessages.contains { $0.contains("\(expectedType) initialized") }, "Logger should log cache initialization")
    }

    func testCreateConverter_DefaultCache() {
        let expectedType = DefaultColorConverter.self
        let converter = factory.createConverter(cache: nil)

        XCTAssertTrue(converter is DefaultColorConverter, "Converter should be \(expectedType)")
        XCTAssertTrue(mockLogger.debugMessages.contains { $0.contains("Default Color Converter initialized") }, "Logger should log converter initialization")
        XCTAssertTrue(mockLogger.debugMessages.contains { $0.contains("GenericCache<UIColor, CIELAB> initialized") }, "Logger should log cache initialization")
    }

    func testCreateConverter_CustomCache() async {
        let expectedType = DefaultColorConverter.self
        let converter = factory.createConverter(cache: mockConverterCache)

        XCTAssertTrue(converter is DefaultColorConverter, "Converter should be \(expectedType)")
        XCTAssertTrue(mockLogger.debugMessages.contains { $0.contains("Default Color Converter initialized") }, "Logger should log converter initialization")
        XCTAssertFalse(mockLogger.debugMessages.contains { $0.contains("GenericCache initialized") }, "Default cache should not be used")
    }

    func testCreateComparator_DefaultCache() {
        let expectedType = DefaultColorComparator.self
        let comparator = factory.createComparator(cache: nil)

        XCTAssertTrue(comparator is DefaultColorComparator, "Comparator should be \(expectedType)")
        XCTAssertTrue(mockLogger.debugMessages.contains { $0.contains("Default Color Comparator initialized") }, "Logger should log comparator initialization")
        XCTAssertTrue(mockLogger.debugMessages.contains { $0.contains("GenericCache<UIColor, UIColor> initialized") }, "Logger should log cache initialization")
    }

    func testCreateComparator_CustomCache() async {
        let expectedType = DefaultColorComparator.self
        let comparator = factory.createComparator(cache: mockComparatorCache)

        XCTAssertTrue(comparator is DefaultColorComparator, "Comparator should be \(expectedType)")
        XCTAssertTrue(mockLogger.debugMessages.contains { $0.contains("Default Color Comparator initialized") }, "Logger should log comparator initialization")
        XCTAssertFalse(mockLogger.debugMessages.contains { $0.contains("GenericCache<UIColor, UIColor> initialized") }, "Default cache should not be used")
    }

    func testLoggerPropagation() async {
        let _ = factory.createLUT()
        let _ = factory.createConverter(cache: nil)
        let _ = factory.createComparator(cache: mockComparatorCache)
        let logs = mockLogger.debugMessages
        
        XCTAssertTrue(logs.contains { $0.contains("ColorLUT initialized with 64 GRC64 entries") }, "LUT should log")
        XCTAssertTrue(logs.contains { $0.contains("Default Color Converter initialized") }, "Converter should log")
        XCTAssertTrue(logs.contains { $0.contains("Default Color Comparator initialized") }, "Comparator should log")
        XCTAssertTrue(logs.contains { $0.contains("GenericCache<UIColor, CIELAB> initialized with max size: 1000") }, "Converter cache should log")
        XCTAssertFalse(logs.contains { $0.contains("GenericCache<UIColor, UIColor> initialized with max size: 1000") }, "Comparator custom cache should not log GenericCache")
    }
}
