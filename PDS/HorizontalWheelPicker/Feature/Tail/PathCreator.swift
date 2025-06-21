import UIKit

private enum PathCreator {
    static func createTailPath(for position: TailPosition, size: CGSize) -> UIBezierPath {
        let manager = TailManager(position: position, size: size)
        return manager.pathStrategy.generatePath(size: manager.actualSize, configuration: manager.configuration)
    }
}
