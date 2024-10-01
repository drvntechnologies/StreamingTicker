//
//  TickerViewModel.swift
//  ESNSTicker
//
//  Created by Cameron Tarbell on 9/30/24.
//

// TickerViewModel.swift

import SwiftUI
import Combine

class TickerViewModel: ObservableObject {
    @Published var items: [TickerItem] = []
    @Published var logo: NSImage? = nil
    
    /// Adds a new ticker item
    func addItem(_ item: TickerItem) {
        items.append(item)
    }
    
    /// Removes items at specified offsets (used for List's onDelete)
    func removeItem(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
    
    /// Removes a specific item (used for contextMenu's Delete)
    func removeItem(item: TickerItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items.remove(at: index)
        }
    }
    
    /// Moves items within the array (used for List's onMove)
    func moveItem(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
    }
    
    /// Updates an existing ticker item
    func updateItem(_ updatedItem: TickerItem) {
        if let index = items.firstIndex(where: { $0.id == updatedItem.id }) {
            items[index] = updatedItem
        }
    }
}
