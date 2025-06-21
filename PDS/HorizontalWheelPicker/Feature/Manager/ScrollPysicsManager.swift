import UIKit

// MARK: - Scroll Physics Manager

final class ScrollPhysicsManager {
    func calculateTargetIndex(currentOffset: CGFloat, velocity: CGFloat,
                              itemWidth: CGFloat, spacing: CGFloat, itemCount: Int) -> Int
    {
        let decelerationRate = calculateDynamicDecelerationRate(velocity: velocity)
        let projectedOffset = calculateProjectedOffset(
            currentOffset: currentOffset,
            velocity: velocity,
            decelerationRate: decelerationRate
        )

        let index = Int(round(projectedOffset / (itemWidth + spacing)))
        return max(0, min(index, itemCount - 1))
    }

    private func calculateDynamicDecelerationRate(velocity: CGFloat) -> CGFloat {
        if abs(velocity) > HorizontalWheelPicker.Constants.velocityThreshold {
            let extraVelocity = abs(velocity) - HorizontalWheelPicker.Constants.velocityThreshold
            return HorizontalWheelPicker.Constants.baseDecelerationRate + extraVelocity * 0.4
        } else {
            return HorizontalWheelPicker.Constants.baseDecelerationRate
        }
    }

    private func calculateProjectedOffset(currentOffset: CGFloat, velocity: CGFloat,
                                          decelerationRate: CGFloat) -> CGFloat
    {
        let clampedDecelerationRate = min(decelerationRate, HorizontalWheelPicker.Constants.maxDecelerationRate)
        return currentOffset + velocity * clampedDecelerationRate * 120
    }
}
