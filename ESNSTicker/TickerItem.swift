//
//  TickerItem.swift
//  ESNSTicker
//
//  Created by Cameron Tarbell on 9/30/24.
// TickerItem.swift

import Foundation

enum TickerItem: Identifiable, Equatable, Codable {
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
    
    // Existing Codable conformance
    enum CodingKeys: CodingKey {
        case type, score, news
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .score(let score):
            try container.encode("score", forKey: .type)
            try container.encode(score, forKey: .score)
        case .news(let news):
            try container.encode("news", forKey: .type)
            try container.encode(news, forKey: .news)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "score":
            let score = try container.decode(ScoreItem.self, forKey: .score)
            self = .score(score)
        case "news":
            let news = try container.decode(NewsItem.self, forKey: .news)
            self = .news(news)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown type")
        }
    }
    
    // Manual Equatable Conformance
    static func == (lhs: TickerItem, rhs: TickerItem) -> Bool {
        switch (lhs, rhs) {
        case (.score(let lhsScore), .score(let rhsScore)):
            return lhsScore == rhsScore
        case (.news(let lhsNews), .news(let rhsNews)):
            return lhsNews == rhsNews
        default:
            return false
        }
    }
    
    /// Retrieves the news text if the item is a news item.
    func getNewsText() -> String {
        switch self {
        case .news(let newsItem):
            return newsItem.text
        case .score:
            return "" // Or any default value you'd prefer
        }
    }
}

struct ScoreItem: Identifiable, Codable, Equatable {
    var id: UUID
    var league: String
    var teamA: String
    var teamB: String
    var startTime: Date
    var additionalInfo: String
    
    init(id: UUID = UUID(), league: String, teamA: String, teamB: String, startTime: Date, additionalInfo: String) {
        self.id = id
        self.league = league
        self.teamA = teamA
        self.teamB = teamB
        self.startTime = startTime
        self.additionalInfo = additionalInfo
    }
}

struct NewsItem: Identifiable, Codable, Equatable {
    var id: UUID
    var text: String
    
    init(id: UUID = UUID(), text: String) {
        self.id = id
        self.text = text
    }
}
