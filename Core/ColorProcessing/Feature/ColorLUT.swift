import ColorProcessingInterface
import LoggerInterface
import UIKit

public class ColorLUT: LUT {
    public typealias Key = UIColor
    public typealias Value = CIELAB

    private var table: [String: CIELAB] = [:]
    private let quantization: Int = 64
    private let lock = NSLock()
    private let logger: Logger?

    /// Segment RGB into 16*16*16(4096) and make CIELAB LUT
    /// NOT USED FOR NOW
    /// - Parameters:
    ///   - converter: ColorConverter
    ///   - logger: Logger
    public init(converter: ColorConverter, logger: Logger? = nil) {
        self.logger = logger
        logger?.debug("ColorLUT for \(quantization)x\(quantization)x\(quantization) initialized")
        buildTable(using: converter)
    }

    /// Make GRC64 into CIELAB LUT
    /// - Parameters:
    ///   - goldenRatioColors: GRC array
    ///   - converter: ColorConverter
    ///   - logger: Logger
    public init(goldenRatioColors: [UIColor], converter: ColorConverter, logger: Logger? = nil) {
        self.logger = logger
        logger?.debug("ColorLUT for GRC\(goldenRatioColors.count) initialized")
        buildTable(from: goldenRatioColors, using: converter)
    }

    /// Find UIColor in table
    /// - Parameter color: Input UIColor
    /// - Returns: CIELAB in table
    public func get(for color: UIColor) -> CIELAB? {
        lock.lock()
        defer { lock.unlock() }
        logger?.debug("Get CIRLAB for \(color)")
        let key = quantizedKey(for: color)
        let result = table[key]
        logger?.debug("Result for \(color) is \(result != nil ? "" : "not ")found")
        return result
    }

    /// Return all colors in table
    /// - Returns: [GRC64(UIColor): GRC64(CIELAB)
    public func getAll() -> [UIColor: CIELAB] {
        lock.lock()
        defer { lock.unlock() }
        logger?.debug("Return all colors in table")
        var result: [UIColor: CIELAB] = [:]
        for (key, lab) in table {
            let components = key.split(separator: ":").compactMap { Float($0) }.compactMap { CGFloat($0) }
            if components.count == 3 {
                let color = UIColor(red: components[0], green: components[1], blue: components[2], alpha: 1)
                result[color] = lab
            }
        }
        return result
    }

    /// Build quantized RGB table using quantization
    /// - Parameter converter: Converter
    private func buildTable(using converter: ColorConverter) {
        logger?.debug("Build table for \(quantization) colors")
        let step = 1.0 / CGFloat(quantization)
        for r in stride(from: 0, to: 1, by: step) {
            for g in stride(from: 0, to: 1, by: step) {
                for b in stride(from: 0, to: 1, by: step) {
                    let color = UIColor(red: r, green: g, blue: b, alpha: 1)
                    let lab = converter.toCIELAB(from: color)
                    let key = quantizedKey(for: color)
                    table[key] = lab
                }
            }
        }
    }

    /// Build GRC64 table using input array
    /// - Parameters:
    ///   - colors: GRC array
    ///   - converter: ColorConverter
    private func buildTable(from colors: [UIColor], using converter: ColorConverter) {
        logger?.debug("Build table for GRC\(colors.count) colors")
        for color in colors {
            let lab = converter.toCIELAB(from: color)
            let key = quantizedKey(for: color)
            table[key] = lab
        }
    }

    /// Table key to store/find UIColor
    /// - Parameter color: UIColor
    /// - Returns: Quantized key for UIColor
    public func quantizedKey(for color: UIColor) -> String {
        logger?.debug("\(quantization) Quantize key for \(color)")
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        let gotRGB = color.getRed(&r, green: &g, blue: &b, alpha: nil)
        guard gotRGB else {
            logger?.debug("Failed to get RGB for color: \(color)")
            return "0.0000:0.0000:0.0000"
        }
        logger?.debug("r: \(r), g: \(g), b: \(b)")
        let step = 1.0 / CGFloat(quantization - 1)
        let qr = round(r / step) * step
        let qg = round(g / step) * step
        let qb = round(b / step) * step
        let key = String(format: "%.4f:%.4f:%.4f", qr, qg, qb)
        logger?.debug("Quantized key: \(key)")
        return key
    }
    
    public func clear() {
        lock.lock()
        defer { lock.unlock() }
        table.removeAll()
    }
}
