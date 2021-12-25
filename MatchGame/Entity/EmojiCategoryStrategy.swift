//
//  EmojiCategoryStrategy.swift
//  MatchGame
//
//  Created by Amir on 12/24/21.
//

import Foundation
 
enum EmojiCategory: CaseIterable, Hashable {
    case emoticons
    case countryFlag
    case transport
    
    var items: ClosedRange<Int> {
        switch self {
        case .emoticons:
            return 0x1F600...0x1F64F
        case .countryFlag:
            return 0x1F1E7...0x1F1FF
        case .transport:
            return 0x1F680...0x1F6FF
        }
    }
    
    func items(range: Int? = nil) -> [String] {
        let charecterItems = items
        return charecterItems.prefix(min(range ?? charecterItems.count, charecterItems.count)).map { String(UnicodeScalar($0) ?? "-") }
    }
}
