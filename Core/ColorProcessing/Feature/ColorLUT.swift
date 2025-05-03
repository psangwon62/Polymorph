import ColorProcessingInterface
import LoggerInterface
import UIKit

public class ColorLUT {
    private var table: [String: CIELAB] = [:]
    private let quantization: Int
    private let lock = NSLock()
    private let logger: Logger?

    /// Segment RGB into 16*16*16(4096) and make CIELAB LUT
    /// NOT USED FOR NOW
    /// - Parameters:
    ///   - quantization: 양자화 정도
    ///   - converter: ColorConverter
    ///   - logger: Logger
    public init(quantization: Int = 16, converter: ColorConverter, logger: Logger? = nil) {
        self.quantization = quantization
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
        quantization = goldenRatioColors.count
        self.logger = logger
        logger?.debug("ColorLUT for GRC\(goldenRatioColors.count) initialized")
        buildTable(from: goldenRatioColors, using: converter)
    }

    /// Find UIColor in table
    /// - Parameter color: Input UIColor
    /// - Returns: CIELAB in table
    public func getCIELAB(for color: UIColor) -> CIELAB? {
        lock.lock()
        defer { lock.unlock() }
        logger?.debug("Get CIRLAB for \(color)")
        let key = quantizedKey(for: color)
        let result = table[key]
        logger?.debug("Result for \(color) is \(result != nil ? "" : "not") found")
        return result
    }

    /// Return all colors in table
    /// - Returns: [GRC64(UIColor): GRC64(CIELAB)
    public func allColors() -> [UIColor: CIELAB] {
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
    private func quantizedKey(for color: UIColor) -> String {
        logger?.debug("Quantize key for \(color)")
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: nil)
        let qr = (Int(r * CGFloat(quantization)) / quantization).clamped(0 ... 1)
        let qg = (Int(g * CGFloat(quantization)) / quantization).clamped(0 ... 1)
        let qb = (Int(b * CGFloat(quantization)) / quantization).clamped(0 ... 1)
        let key = "\(qr):\(qg):\(qb)"
        logger?.debug("Quantized key: \(key)")
        return key
    }
}
