import ColorProcessingInterface
import ColorProcessingTesting
import LoggerInterface
import UIKit

public class GRC64LUT: LUT {
    public typealias Key = UIColor
    public typealias Value = CIELAB

    private let table: [UIColor: CIELAB]
    private let logger: Logger?

    public init(logger: Logger? = nil) {
        self.logger = logger
        table = [
            UIColor(hex: "000000"): CIELAB(L: 0.000, a: 0.000, b: 0.000),
            UIColor(hex: "000061"): CIELAB(L: 7.793, a: 39.001, b: -53.130),
            UIColor(hex: "00009E"): CIELAB(L: 17.772, a: 55.373, b: -75.422),
            UIColor(hex: "0000FF"): CIELAB(L: 32.297, a: 79.188, b: -107.860),
            UIColor(hex: "006100"): CIELAB(L: 35.101, a: -42.454, b: 40.975),
            UIColor(hex: "006161"): CIELAB(L: 36.765, a: -23.688, b: -6.961),
            UIColor(hex: "00619E"): CIELAB(L: 39.608, a: -0.207, b: -39.699),
            UIColor(hex: "0061FF"): CIELAB(L: 46.666, a: 38.354, b: -84.036),
            UIColor(hex: "009E00"): CIELAB(L: 56.538, a: -60.264, b: 58.164),
            UIColor(hex: "009E61"): CIELAB(L: 57.381, a: -49.853, b: 22.236),
            UIColor(hex: "009E9E"): CIELAB(L: 58.900, a: -33.626, b: -9.881),
            UIColor(hex: "009EFF"): CIELAB(L: 63.069, a: 0.636, b: -57.499),
            UIColor(hex: "00FF00"): CIELAB(L: 87.735, a: -86.183, b: 83.179),
            UIColor(hex: "00FF61"): CIELAB(L: 88.150, a: -80.857, b: 59.978),
            UIColor(hex: "00FF9E"): CIELAB(L: 88.914, a: -71.600, b: 32.564),
            UIColor(hex: "00FFFF"): CIELAB(L: 91.113, a: -48.088, b: -14.131),
            UIColor(hex: "610000"): CIELAB(L: 18.109, a: 39.454, b: 27.916),
            UIColor(hex: "610061"): CIELAB(L: 21.598, a: 48.391, b: -29.963),
            UIColor(hex: "61009E"): CIELAB(L: 26.763, a: 60.073, b: -60.237),
            UIColor(hex: "6100FF"): CIELAB(L: 37.408, a: 81.255, b: -99.203),
            UIColor(hex: "616100"): CIELAB(L: 39.733, a: -10.618, b: 46.541),
            UIColor(hex: "616161"): CIELAB(L: 41.143, a: -0.000, b: 0.000),
            UIColor(hex: "61619E"): CIELAB(L: 43.593, a: 15.562, b: -33.136),
            UIColor(hex: "6161FF"): CIELAB(L: 49.868, a: 45.775, b: -78.669),
            UIColor(hex: "619E00"): CIELAB(L: 58.969, a: -40.568, b: 61.115),
            UIColor(hex: "619E61"): CIELAB(L: 59.759, a: -32.597, b: 25.819),
            UIColor(hex: "619E9E"): CIELAB(L: 61.187, a: -19.661, b: -6.230),
            UIColor(hex: "619EFF"): CIELAB(L: 65.130, a: 9.365, b: -54.096),
            UIColor(hex: "61FF00"): CIELAB(L: 88.950, a: -75.539, b: 84.660),
            UIColor(hex: "61FF61"): CIELAB(L: 89.356, a: -70.744, b: 61.662),
            UIColor(hex: "61FF9E"): CIELAB(L: 90.103, a: -62.351, b: 34.356),
            UIColor(hex: "61FFFF"): CIELAB(L: 92.254, a: -40.737, b: -12.308),
            UIColor(hex: "9E0000"): CIELAB(L: 32.417, a: 56.006, b: 46.437),
            UIColor(hex: "9E0061"): CIELAB(L: 34.261, a: 60.918, b: -9.288),
            UIColor(hex: "9E009E"): CIELAB(L: 37.371, a: 68.691, b: -42.532),
            UIColor(hex: "9E00FF"): CIELAB(L: 44.926, a: 85.751, b: -86.528),
            UIColor(hex: "9E6100"): CIELAB(L: 46.738, a: 18.700, b: 54.654),
            UIColor(hex: "9E6161"): CIELAB(L: 47.858, a: 24.766, b: 10.506),
            UIColor(hex: "9E619E"): CIELAB(L: 49.844, a: 34.600, b: -22.927),
            UIColor(hex: "9E61FF"): CIELAB(L: 55.111, a: 56.652, b: -69.913),
            UIColor(hex: "9E9E00"): CIELAB(L: 63.114, a: -15.072, b: 66.065),
            UIColor(hex: "9E9E61"): CIELAB(L: 63.825, a: -9.467, b: 31.878),
            UIColor(hex: "9E9E9E"): CIELAB(L: 65.114, a: -0.000, b: 0.000),
            UIColor(hex: "9E9EFF"): CIELAB(L: 68.709, a: 22.754, b: -48.206),
            UIColor(hex: "9EFF00"): CIELAB(L: 91.138, a: -58.550, b: 87.310),
            UIColor(hex: "9EFF61"): CIELAB(L: 91.527, a: -54.497, b: 64.680),
            UIColor(hex: "9EFF9E"): CIELAB(L: 92.245, a: -47.333, b: 37.574),
            UIColor(hex: "9EFFFF"): CIELAB(L: 94.314, a: -28.512, b: -9.021),
            UIColor(hex: "FF0000"): CIELAB(L: 53.241, a: 80.092, b: 67.203),
            UIColor(hex: "FF0061"): CIELAB(L: 54.165, a: 82.597, b: 21.757),
            UIColor(hex: "FF009E"): CIELAB(L: 55.822, a: 86.973, b: -12.420),
            UIColor(hex: "FF00FF"): CIELAB(L: 60.324, a: 98.234, b: -60.825),
            UIColor(hex: "FF6100"): CIELAB(L: 61.495, a: 57.162, b: 70.892),
            UIColor(hex: "FF6161"): CIELAB(L: 62.236, a: 60.055, b: 32.247),
            UIColor(hex: "FF619E"): CIELAB(L: 63.577, a: 65.120, b: -0.903),
            UIColor(hex: "FF61FF"): CIELAB(L: 67.302, a: 78.186, b: -49.732),
            UIColor(hex: "FF9E00"): CIELAB(L: 73.363, a: 27.575, b: 77.930),
            UIColor(hex: "FF9E61"): CIELAB(L: 73.922, a: 30.644, b: 46.570),
            UIColor(hex: "FF9E9E"): CIELAB(L: 74.943, a: 36.066, b: 15.370),
            UIColor(hex: "FF9EFF"): CIELAB(L: 77.838, a: 50.296, b: -33.288),
            UIColor(hex: "FFFF00"): CIELAB(L: 97.139, a: -21.554, b: 94.478),
            UIColor(hex: "FFFF61"): CIELAB(L: 97.489, a: -18.749, b: 72.856),
            UIColor(hex: "FFFF9E"): CIELAB(L: 98.134, a: -13.710, b: 46.337),
            UIColor(hex: "FFFFFF"): CIELAB(L: 100.000, a: -0.000, b: 0.000),
        ]
        logger?.debug("ColorLUT initialized with \(table.count) GRC64 entries")
    }

    /// Find UIColor in table
    /// - Parameter color: Input UIColor
    /// - Returns: CIELAB in table
    public func get(for color: UIColor) -> CIELAB? {
        logger?.debug("Get CIELAB for \(color)")
        let result = table[color]
        logger?.debug("Result for \(color) is \(result != nil ? "" : "not ")found")
        return result
    }

    /// Return all colors in table
    /// - Returns: [GRC64(UIColor): GRC64(CIELAB)]
    public func getAll() -> [UIColor: CIELAB] {
        logger?.debug("Return all colors in table")
        return table
    }
}
