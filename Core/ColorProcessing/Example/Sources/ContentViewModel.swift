import ColorProcessingInterface
import SwiftUI
import UIKit

public class ContentViewModel: ObservableObject {
    @Published var selectedColor: Color = .init(uiColor: UIColor(hex: "FF0000"))
    @Published var closestColor: Color? = nil
    let comparator: ColorComparator

    init(comparator: ColorComparator) {
        self.comparator = comparator
    }

    @MainActor
    public func closestColor() async {
        let closest = await comparator.closestGoldenRatioColor(to: UIColor(selectedColor))
        closestColor = Color(uiColor: closest)
    }
}

public extension UIColor {
    convenience init(hex: String) {
        let cleanHex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#")).uppercased()
        guard cleanHex.count == 6, cleanHex.allSatisfy({ $0.isHexDigit }) else {
            self.init(red: 0, green: 0, blue: 0, alpha: 1)
            return
        }

        let scanner = Scanner(string: cleanHex)
        var rgb: UInt64 = 0
        guard scanner.scanHexInt64(&rgb) else {
            self.init(red: 0, green: 0, blue: 0, alpha: 1)
            return
        }

        let red = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let green = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let blue = CGFloat(rgb & 0xFF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}
