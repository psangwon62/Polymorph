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
//            Logger.log("Invalid hex string: \(hex), returning black")
            self.init(red: 0, green: 0, blue: 0, alpha: 1)
            return
        }

        // 2. Hex → RGB 변환
        let scanner = Scanner(string: cleanHex)
        var rgb: UInt64 = 0
        guard scanner.scanHexInt64(&rgb) else {
//            Logger.log("Failed to scan hex: \(cleanHex), returning black")
            self.init(red: 0, green: 0, blue: 0, alpha: 1)
            return
        }

        let red = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let green = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let blue = CGFloat(rgb & 0xFF) / 255.0
//        Logger.log("Hex \(hex) -> RGB: R:\(red), G:\(green), B:\(blue)")

        // 3. UIColor 생성
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }

    /// Hex 문자열로 UIColor 생성 (정적 메서드, 옵셔널 리턴)
    /// - Parameter hex: Hex 색상 문자열
    /// - Returns: UIColor 또는 nil (유효하지 않은 경우)
    static func fromHex(_ hex: String) -> UIColor? {
        let cleanHex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#")).uppercased()
        guard cleanHex.count == 6, cleanHex.allSatisfy({ $0.isHexDigit }) else {
//            Logger.log("Invalid hex string: \(hex)")
            return nil
        }

        let scanner = Scanner(string: cleanHex)
        var rgb: UInt64 = 0
        guard scanner.scanHexInt64(&rgb) else {
//            Logger.log("Failed to scan hex: \(cleanHex)")
            return nil
        }

        let red = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let green = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let blue = CGFloat(rgb & 0xFF) / 255.0
//        Logger.log("Hex \(hex) -> RGB: R:\(red), G:\(green), B:\(blue)")

        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
}
