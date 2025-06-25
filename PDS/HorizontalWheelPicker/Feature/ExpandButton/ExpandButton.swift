import UIKit

final class ExpandButton: UIButton {
    // MARK: - Private Properties

    private let maskLayer = CAShapeLayer()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Setup

    private func setup() {
        layer.mask = maskLayer
    }

    // MARK: - Path Creation

    private func createMask() -> UIBezierPath {
        topMaskPath()
    }

    private func topMaskPath() -> UIBezierPath {
        let path = UIBezierPath()
        let width = bounds.width
        let height = bounds.height
        let curveIntensity: CGFloat = 0.25
        path.move(to: CGPoint(x: 0, y: height))
        path.addCurve(
            to: CGPoint(x: width * curveIntensity, y: 0),
            controlPoint1: CGPoint(x: width * curveIntensity, y: height),
            controlPoint2: CGPoint(x: width * curveIntensity / 2, y: 0)
        )
        path.addLine(to: CGPoint(x: width * (1 - curveIntensity), y: 0))
        path.addCurve(
            to: CGPoint(x: width, y: height),
            controlPoint1: CGPoint(x: width * (1 - curveIntensity / 2), y: 0),
            controlPoint2: CGPoint(x: width * (1 - curveIntensity), y: height)
        )

        path.close()
        return path
    }

    private func bottomMaskPath() -> UIBezierPath {
        let path = UIBezierPath()
        let width = bounds.width
        let height = bounds.height
        let curveIntensity: CGFloat = 0.25
        path.move(to: CGPoint(x: width, y: 0))
        path.addCurve(
            to: CGPoint(x: width * (1 - curveIntensity), y: height),
            controlPoint1: CGPoint(x: width * (1 - curveIntensity), y: 0),
            controlPoint2: CGPoint(x: width * (1 - curveIntensity / 2), y: height)
        )
        path.addLine(to: CGPoint(x: width * curveIntensity, y: height))
        path.addCurve(
            to: CGPoint(x: 0, y: 0),
            controlPoint1: CGPoint(x: width * curveIntensity / 2, y: height),
            controlPoint2: CGPoint(x: width * curveIntensity, y: 0)
        )

        path.close()
        return path
    }

    private func leftMaskPath() -> UIBezierPath {
        let path = UIBezierPath()
        let width = bounds.height
        let height = bounds.width
        let curveIntensity: CGFloat = 0.25

        path.move(to: CGPoint.zero)
        path.addCurve(
            to: CGPoint(x: width, y: height * curveIntensity),
            controlPoint1: CGPoint(x: 0, y: height * curveIntensity),
            controlPoint2: CGPoint(x: width, y: height * curveIntensity / 2)
        )
        path.addLine(to: CGPoint(x: width, y: height * (1 - curveIntensity)))
        path.addCurve(
            to: CGPoint(x: 0, y: height),
            controlPoint1: CGPoint(x: width, y: height * (1 - curveIntensity / 2)),
            controlPoint2: CGPoint(x: 0, y: height * (1 - curveIntensity))
        )
        path.close()

        return path
    }

    private func rightMaskPath() -> UIBezierPath {
        let path = UIBezierPath()
        let width = bounds.height
        let height = bounds.width
        let curveIntensity: CGFloat = 0.25

        path.move(to: CGPoint(x: width, y: height))
        path.addCurve(
            to: CGPoint(x: 0, y: height * (1 - curveIntensity)),
            controlPoint1: CGPoint(x: width, y: height * (1 - curveIntensity)),
            controlPoint2: CGPoint(x: 0, y: height * (1 - curveIntensity / 2))
        )
        path.addLine(to: CGPoint(x: 0, y: height * curveIntensity))
        path.addCurve(
            to: CGPoint(x: width, y: 0),
            controlPoint1: CGPoint(x: 0, y: height * curveIntensity / 2),
            controlPoint2: CGPoint(x: width, y: height * curveIntensity)
        )
        path.close()

        return path
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        maskLayer.path = createMask().cgPath
    }
}
