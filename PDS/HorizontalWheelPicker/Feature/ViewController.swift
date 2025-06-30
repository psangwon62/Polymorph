import UIKit
import ReactorKit
import RxSwift

public class ViewController: UIViewController {
    private let wheelPicker = HorizontalWheelPicker()
    private let resultLabel = UILabel()
    private let disposeBag = DisposeBag()
    private let emojis = ["😀", "😎", "🤔", "👽", "🤖", "👾", "😈", "👻", "🤡", "🎉"]
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupWheelPicker()
        view.backgroundColor = .systemBlue
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutViews()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        resultLabel.text = "Selected: 😎"
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
        // Reactor 생성 및 주입
        let reactor = HorizontalWheelPickerReactor(items: emojis, selectedIndex: 1)
        wheelPicker.reactor = reactor
        
        wheelPicker.configuration.itemWidth = 60
        wheelPicker.configuration.itemHeight = 60
        wheelPicker.configuration.font = .systemFont(ofSize: 40)
        wheelPicker.configuration.selectedTextColor = .label
        wheelPicker.configuration.deselectedTextColor = .secondaryLabel
        wheelPicker.configuration.selectionIndicatorColor = .systemBlue
        wheelPicker.configuration.tailPosition = .top
        
        // Rx로 선택 이벤트 구독하여 라벨 업데이트
        wheelPicker.rx_itemSelected
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                self.resultLabel.text = "Selected: \(self.emojis[index])"
            })
            .disposed(by: disposeBag)
    }
}
