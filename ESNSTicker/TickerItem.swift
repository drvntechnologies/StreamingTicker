//
//  TickerItem.swift
//  ESNSTicker
//
//  Created by Cameron Tarbell on 9/30/24.
//

import Foundation

enum TickerItem: Identifiable, Equatable {
    case score(ScoreItem)
    case news(NewsItem)
    
    var id: UUID {
        switch self {
        case .score(let score):
            return score.id
        case .news(let news):
            return news.id
        }
    }
    
    static func == (lhs: TickerItem, rhs: TickerItem) -> Bool {
        return lhs.id == rhs.id
    }
}
