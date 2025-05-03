import ColorProcessingInterface
import LoggerInterface
import UIKit

public class DefaultColorComparator: ColorComparator {
    private let converter: ColorConverter
    private let goldenRatioLUT: ColorLUT
    private let cache: ComparatorCache
    private let logger: Logger?

    public init(
        converter: ColorConverter,
        goldenRatioColors: [UIColor],
        logger: Logger? = nil
    ) {
        self.converter = converter
        goldenRatioLUT = ColorLUT(goldenRatioColors: goldenRatioColors, converter: converter, logger: logger)
        cache = ComparatorCache(logger: logger)
        self.logger = logger
        self.logger?.debug("Default Color Comparator initialized")
    }
    
    /// Calculate difference betwwen two UIColors using CIE76
    /// - Parameters:
    ///   - color1: UIColor 1
    ///   - color2: UIColor 2
    /// - Returns: Diffence btw 2 colors
    public func difference(between color1: UIColor, and color2: UIColor) -> CGFloat {
        logger?.debug("[UIColor] Calculate difference between \(color1) and \(color2)")
        let lab1 = converter.toCIELAB(from: color1)
        let lab2 = converter.toCIELAB(from: color2)
        let result = difference(between: lab1, and: lab2)
        logger?.debug("[UIColor] Difference between \(lab1) and \(lab2) is \(result)")
        return result
    }
    
    /// Calculate difference between two CIELAB Colors using CIE76
    /// - Parameters:
    ///   - lab1: CIELAB Color 1
    ///   - lab2: CIELAB Color 2
    /// - Returns: Difference btw 2 colors
    public func difference(between lab1: CIELAB, and lab2: CIELAB) -> CGFloat {
        logger?.debug("[CIELAB] Calculate difference between \(lab1) and \(lab2)")
        let deltaL = lab2.L - lab1.L
        let deltaA = lab2.a - lab1.a
        let deltaB = lab2.b - lab1.b
        let difference = sqrt(pow(deltaL, 2) + pow(deltaA, 2) + pow(deltaB, 2))
        logger?.debug("[CIELAB] Different between \(lab1) and \(lab2) is \(difference)")
        return difference
    }
    
    /// Get and cache closest GRC from input
    /// - Parameter color: Input UIColor
    /// - Returns: Closest GRC UIColor
    public func closestGoldenRatioColor(to color: UIColor) -> UIColor {
        cache.getClosestColor(for: color) { input in
            let inputLAB = converter.toCIELAB(from: input)
            let goldenColors = goldenRatioLUT.allColors()
            var closestColor: UIColor?
            var minDeltaE: CGFloat = .greatestFiniteMagnitude
            
            for (goldenColor, goldenLAB) in goldenColors {
                let deltaE = difference(between: inputLAB, and: goldenLAB)
                if deltaE < minDeltaE {
                    minDeltaE = deltaE
                    closestColor = goldenColor
                }
            }

            return closestColor ?? goldenColors.keys.first ?? UIColor.black
        }
    }
}
