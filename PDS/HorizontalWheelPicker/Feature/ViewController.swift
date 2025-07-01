import ReactorKit
import UIKit

public class ViewController: UIViewController {
    private let wheelPicker = HorizontalWheelPicker()
    private let resultLabel = UILabel()
    private let disposeBag = DisposeBag()
    private let emojis = ["😀", "😎", "🤔", "👽", "🤖", "👾", "😈", "👻", "🤡", "🎉"]

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupWheelPicker()
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutViews()
    }

    private func setupUI() {
        view.backgroundColor = .systemBrown

        resultLabel.font = .systemFont(ofSize: 24, weight: .medium)
        resultLabel.textAlignment = .center

        view.addSubview(resultLabel)
        view.addSubview(wheelPicker)
    }

    private func layoutViews() {
        resultLabel.pin
            .top(view.pin.safeArea.top + 50)
            .horizontally(20)
            .sizeToFit(.width)

        let tailSpace = wheelPicker.configuration.tailSize.height
        wheelPicker.pin
            .center()
            .size(CGSize(width: 300, height: 80 + tailSpace))
    }

    private func setupWheelPicker() {
        let reactor = HorizontalWheelPickerReactor(items: emojis, selectedIndex: 0)
        wheelPicker.reactor = reactor

        wheelPicker.configuration.itemWidth = 60
        wheelPicker.configuration.itemHeight = 60
        wheelPicker.configuration.font = .systemFont(ofSize: 40)
        wheelPicker.configuration.selectedTextColor = .label
        wheelPicker.configuration.deselectedTextColor = .secondaryLabel
        wheelPicker.configuration.selectionIndicatorColor = .systemBlue
        wheelPicker.configuration.tailPosition = .bottom

        reactor.state
            .map { $0.selectedIndex }
            .distinctUntilChanged()
            .map { [weak self] index in
                guard let self = self else { return "" }
                guard self.emojis.indices.contains(index) else { return "Selected: ??" }
                return "Selected: \(self.emojis[index])"
            }
            .bind(to: resultLabel.rx.text)
            .disposed(by: disposeBag)
    }
}
