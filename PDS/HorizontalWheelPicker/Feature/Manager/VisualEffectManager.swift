import UIKit

// MARK: - Visual Effects Manager

struct VisualEffects {
    let scale: CGFloat
    let alpha: CGFloat
    let textColor: UIColor
}

final class VisualEffectsManager {
    func calculateEffects(distance: CGFloat, itemWidth: CGFloat,
                          selectedColor: UIColor, deselectedColor: UIColor) -> VisualEffects
    {
        let threshold = itemWidth * HorizontalWheelPicker.Constants.centerProximityThreshold
        
        if distance < threshold {
            let centerProximity = 1.0 - (distance/threshold)
            let scale = 1.0 + HorizontalWheelPicker.Constants.maxScaleBoost * centerProximity
            return VisualEffects(scale: scale, alpha: 1.0, textColor: selectedColor)
        } else {
            let scale = calculateScale(distance: distance, itemWidth: itemWidth)
            let alpha = calculateOpacity(distance: distance, itemWidth: itemWidth)
            let textColor = calculateTextColor(distance: distance, itemWidth: itemWidth,
                                               from: deselectedColor, to: selectedColor)
            return VisualEffects(scale: scale, alpha: alpha, textColor: textColor)
        }
    }
    
    func calculateStaticEffects(isSelected: Bool, distance: CGFloat,
                                selectedColor: UIColor, deselectedColor: UIColor) -> VisualEffects
    {
        if isSelected {
            return VisualEffects(scale: 1.0, alpha: 1.0, textColor: selectedColor)
        } else {
            let scale = max(HorizontalWheelPicker.Constants.minScale, 1.0 - distance * 0.15)
            let alpha = max(HorizontalWheelPicker.Constants.minOpacity, 1.0 - distance * 0.35)
            return VisualEffects(scale: scale, alpha: alpha, textColor: deselectedColor)
        }
    }
    
    func applyRealTimeEffects(to label: UILabel, effects: VisualEffects) {
        label.transform = CGAffineTransform(scaleX: effects.scale, y: effects.scale)
        label.alpha = effects.alpha
        label.textColor = effects.textColor
    }
    
    func animateEffects(to label: UILabel, effects: VisualEffects) {
        UIView.animate(withDuration: HorizontalWheelPicker.Constants.animationDuration,
                       delay: 0, options: .curveEaseOut)
        {
            label.transform = CGAffineTransform(scaleX: effects.scale, y: effects.scale)
            label.alpha = effects.alpha
            label.textColor = effects.textColor
        }
    }
    
    // MARK: - Private Calculation Methods
    
    private func calculateSmoothValue(distance: CGFloat, maxDistance: CGFloat,
                                      minValue: CGFloat, maxValue: CGFloat) -> CGFloat
    {
        let normalizedDistance = min(distance/maxDistance, 1.0)
        let result = minValue + maxValue * cos(normalizedDistance * .pi/2)
        return max(minValue, result)
    }
    
    private func calculateScale(distance: CGFloat, itemWidth: CGFloat) -> CGFloat {
        return calculateSmoothValue(
            distance: distance,
            maxDistance: itemWidth * 2.5,
            minValue: HorizontalWheelPicker.Constants.minScale,
            maxValue: 0.3
        )
    }
    
    private func calculateOpacity(distance: CGFloat, itemWidth: CGFloat) -> CGFloat {
        return calculateSmoothValue(
            distance: distance,
            maxDistance: itemWidth * 3.5,
            minValue: HorizontalWheelPicker.Constants.minOpacity,
            maxValue: 0.7
        )
    }
    
    private func calculateTextColor(distance: CGFloat, itemWidth: CGFloat,
                                    from: UIColor, to: UIColor) -> UIColor
    {
        let maxDistance = itemWidth * 1.5
        let normalizedDistance = min(distance/maxDistance, 1.0)
        let colorRatio = cos(normalizedDistance * .pi/2)
        return UIColor.interpolate(from: from, to: to, ratio: colorRatio)
    }
}
