import UIKit

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

    var hex: String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: nil)
        return String(format: "%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}
