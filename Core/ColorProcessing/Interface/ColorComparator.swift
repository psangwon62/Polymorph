import UIKit

// TODO: - 거리 비교 가능한 색상 타입을 통틀어서 사용할 수 있는 프로토콜(임시: Measureable)로 함수 간략화
public protocol ColorComparator {
    func difference(between color1: UIColor, and color2: UIColor) async -> CGFloat
    func difference(between lab1: CIELAB, and lab2: CIELAB) -> CGFloat
    func closestGoldenRatioColor(to color: UIColor) async -> UIColor
}
