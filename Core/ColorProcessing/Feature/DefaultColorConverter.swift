import ColorProcessingInterface
import LoggerInterface
import UIKit

/// Class that converts RGB to CIELAB
public class DefaultColorConverter: ColorConverter {
    private enum Constant {
        static let d65: (X: CGFloat, Y: CGFloat, Z: CGFloat) = (95.047, 100.000, 108.883)
        static let oneThird: CGFloat = 1.0 / 3.0
        static let fourOverTwentyNine: CGFloat = 4.0 / 29.0
        static let delta: CGFloat = 6.0 / 29.0
        static let deltaCubed: CGFloat = delta * delta * delta
        static let deltaSquaredTimesThree: CGFloat = delta * delta * 3.0
    }

    struct CIEXYZ: Hashable {
        var X: CGFloat
        var Y: CGFloat
        var Z: CGFloat
    }

    private let lut: any LUT<UIColor, CIELAB>
    private let cache: any CacheProtocol<UIColor, CIELAB>
    private let logger: Logger?

    public init(lut: any LUT<UIColor, CIELAB>, cache: any CacheProtocol<UIColor, CIELAB>, logger: Logger? = nil) {
        self.lut = lut
        self.cache = cache
        self.logger = logger
        logger?.debug("Color Converter initialized")
    }

    /// Convert UIColor to CIELAB
    /// - Parameter color: Input UIColor
    /// - Returns: Converted CIELAB Color
    public func toCIELAB(from color: UIColor) async -> CIELAB {
        if let lab = lut.get(for: color) {
            logger?.debug("LUT hit for color: \(color)")
            return lab
        }
        return await cache.get(for: color) { [weak self] color in
            guard let self else { return CIELAB(L: 0, a: 0, b: 0) }
            logger?.debug("Computing CIELAB for color: \(color)")
            let lab = self.computeCIELAB(from: color)
            logger?.debug("Computed CIELAB: \(lab)")
            return lab
        }
    }
    
    /// Compute UIColor -> CIEXYZ -> CIELAB
    /// - Parameter color: Input UIColor
    /// - Returns: Converted CIELAB
    private func computeCIELAB(from color: UIColor) -> CIELAB {
        let xyz = toCIEXYZ(from: color)
        let ref = Constant.d65

        func fn(_ t: CGFloat) -> CGFloat {
            if t > Constant.deltaCubed { return pow(t, Constant.oneThird) }
            return (t / Constant.deltaSquaredTimesThree) + Constant.fourOverTwentyNine
        }

        let fx = fn(xyz.X / ref.X)
        let fy = fn(xyz.Y / ref.Y)
        let fz = fn(xyz.Z / ref.Z)

        let L = 116.0 * fy - 16.0
        let a = 500.0 * (fx - fy)
        let b = 200.0 * (fy - fz)

        return CIELAB(L: L, a: a, b: b)
    }

    /// Convert CIELAB to UIColor
    /// - Parameters:
    ///   - lab: Input CIELAB Color
    ///   - alpha: Alpha value
    /// - Returns: Converted UIColor
    public func fromCIELAB(_ lab: CIELAB, alpha: CGFloat) -> UIColor {
        func fn(_ t: CGFloat) -> CGFloat {
            if t > Constant.delta { return pow(t, 3.0) }
            return Constant.deltaSquaredTimesThree * (t - Constant.fourOverTwentyNine)
        }

        let ref = Constant.d65
        let L = (lab.L + 16.0) / 116.0
        let a = L + (lab.a / 500.0)
        let b = L - (lab.b / 200.0)

        let X = fn(a) * ref.X
        let Y = fn(L) * ref.Y
        let Z = fn(b) * ref.Z

        return fromCIEXYZ(CIEXYZ(X: X, Y: Y, Z: Z), alpha: alpha)
    }

    /// Convert UIColor to CIEXYZ
    /// - Parameter color: Input UIColor
    /// - Returns: Converted CIEXYZ
    func toCIEXYZ(from color: UIColor) -> CIEXYZ {
        var (r, g, b) = (CGFloat(), CGFloat(), CGFloat())
        guard color.getRed(&r, green: &g, blue: &b, alpha: nil),
              (0 ... 1).contains(r), (0 ... 1).contains(g), (0 ... 1).contains(b) else
        {
            return CIEXYZ(X: 0, Y: 0, Z: 0)
        }

        r = (r > 0.04045) ? pow((r + 0.055) / 1.055, 2.4) : (r / 12.92)
        g = (g > 0.04045) ? pow((g + 0.055) / 1.055, 2.4) : (g / 12.92)
        b = (b > 0.04045) ? pow((b + 0.055) / 1.055, 2.4) : (b / 12.92)

        let X = (0.4124564 * r) + (0.3575761 * g) + (0.1804375 * b)
        let Y = (0.2126729 * r) + (0.7151522 * g) + (0.0721750 * b)
        let Z = (0.0193339 * r) + (0.1191920 * g) + (0.9503041 * b)

        return CIEXYZ(X: X * 100.0, Y: Y * 100.0, Z: Z * 100.0)
    }

    /// Convert CIEXYZ to UIColor
    /// - Parameters:
    ///   - xyz: Input CIEXYZ Color
    ///   - alpha: Alpha value
    /// - Returns: Converted UIColor
    func fromCIEXYZ(_ xyz: CIEXYZ, alpha: CGFloat) -> UIColor {
        let X = max(0, xyz.X) / 100.0
        let Y = max(0, xyz.Y) / 100.0
        let Z = max(0, xyz.Z) / 100.0

        var r = (3.2404542 * X) - (1.5371385 * Y) - (0.4985314 * Z)
        var g = (-0.9692660 * X) + (1.8760108 * Y) + (0.0415560 * Z)
        var b = (0.0556434 * X) - (0.2040259 * Y) + (1.0572252 * Z)

        let k: CGFloat = 1.0 / 2.4
        r = (r <= 0.00304) ? (12.92 * r) : (1.055 * pow(r, k) - 0.055)
        g = (g <= 0.00304) ? (12.92 * g) : (1.055 * pow(g, k) - 0.055)
        b = (b <= 0.00304) ? (12.92 * b) : (1.055 * pow(b, k) - 0.055)

        r = r.clamped(0 ... 1)
        g = g.clamped(0 ... 1)
        b = b.clamped(0 ... 1)

        return UIColor(red: r, green: g, blue: b, alpha: alpha)
    }
}
