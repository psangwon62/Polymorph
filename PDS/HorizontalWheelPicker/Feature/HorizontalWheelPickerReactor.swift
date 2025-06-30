import ReactorKit
import RxSwift

public final class HorizontalWheelPickerReactor: Reactor {
    public enum Action {
        case selectItem(Int)
        case setItems([String])
        case scrollToIndex(Int)
    }

    public enum Mutation {
        case setSelectedIndex(Int)
        case setItems([String])
    }

    public struct State {
        var items: [String]
        var selectedIndex: Int
    }

    public let initialState: State
    public init(items: [String] = [], selectedIndex: Int = 0) {
        initialState = State(items: items, selectedIndex: selectedIndex)
    }

    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
            case let .selectItem(index):
                return .just(.setSelectedIndex(index))
            case let .setItems(items):
                return .just(.setItems(items))
            case let .scrollToIndex(index):
                return .just(.setSelectedIndex(index))
        }
    }

    public func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
            case let .setSelectedIndex(index):
                state.selectedIndex = index
            case let .setItems(items):
                state.items = items
        }
        return state
    }
} 