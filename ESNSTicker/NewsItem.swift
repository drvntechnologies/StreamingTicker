//
//  NewsItem.swift
//  ESNSTicker
//
//  Created by Cameron Tarbell on 9/30/24.
//

import Foundation

struct NewsItem: Identifiable, Equatable {
    var id: UUID = UUID()
    var text: String
}
