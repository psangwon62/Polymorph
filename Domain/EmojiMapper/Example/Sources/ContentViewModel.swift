import Foundation
import EmojiMapperInterface

final class ContentViewModel: ObservableObject {
    @Published var mapper: EmojiMapper
    
    init(mapper: EmojiMapper) {
        self.mapper = mapper
    }
    
    
}
