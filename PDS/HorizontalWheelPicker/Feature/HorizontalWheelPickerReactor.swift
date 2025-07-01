import ReactorKit

public final class HorizontalWheelPickerReactor: Reactor {
    // MARK: - Action

    public enum Action {
        case selectItem(Int)
        case expandButtonTapped
    }

    // MARK: - Mutation

    public enum Mutation {
        case setSelectedIndex(Int)
    }

    // MARK: - State

    public struct State {
        var items: [String]
        var selectedIndex: Int
    }

    public let initialState: State

    // MARK: - Initialize

    public init(items: [String] = [], selectedIndex: Int = 0) {
        initialState = State(items: items, selectedIndex: selectedIndex)
    }

    // MARK: - Mutate

    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
            case let .selectItem(index):
                guard currentState.selectedIndex != index else { return .empty() }
                return .just(.setSelectedIndex(index))

            case .expandButtonTapped:
                return Observable<Void>.just(())
                    .do(onNext: { _ in
                        print("hello")
                    })
                    .flatMap { Observable<Mutation>.empty() }
        }
    }

    // MARK: - Reduce

    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
            case let .setSelectedIndex(index):
                newState.selectedIndex = index
        }
        return newState
    }
}
