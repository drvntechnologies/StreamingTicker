//
//  ScoreItem.swift
//  ESNSTicker
//
//  Created by Cameron Tarbell on 9/30/24.
//

import Foundation

struct ScoreItem: Identifiable, Equatable {
    var id: UUID = UUID()
    var league: String
    var teamA: String
    var teamB: String
    var startTime: Date
    var additionalInfo: String
}
