//
//  TickerViewModel.swift
//  ESNSTicker
//
//  Created by Cameron Tarbell on 9/30/24.
//

import SwiftUI
import Combine

class TickerViewModel: ObservableObject {
    @Published var items: [TickerItem] = []
    @Published var logo: NSImage? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {}
    
    func addItem(_ item: TickerItem) {
        items.append(item)
    }
    
    func removeItem(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
    
    func moveItem(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
    }
    
    func updateItem(_ item: TickerItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
        }
    }
}
