//
//  ControlView.swift
//  ESNSTicker
//
//  Created by Cameron Tarbell on 9/30/24.
//

import SwiftUI

struct ControlView: View {
    @ObservedObject var viewModel: TickerViewModel
    @State private var showingAddItem = false
    @State private var selectedItem: TickerItem? = nil
    @State private var showingEditItem = false
    @State private var showingImagePicker = false
    @State private var showingDeleteConfirmation = false
    @State private var itemToDelete: TickerItem? = nil
    @State private var showingSuccessAlert = false
    @State private var successMessage = ""
    
    var body: some View {
        VStack {
            // Header with Title and Add Button
            HStack {
                Text("Ticker Timeline")
                    .font(.largeTitle)
                Spacer()
                Button(action: {
                    showingAddItem = true
                }) {
                    Image(systemName: "plus.circle")
                        .font(.title)
                }
                .help("Add a new ticker item")
            }
            .padding()
            
            // List of Ticker Items
            List {
                ForEach(viewModel.items) { item in
                    HStack {
                        if case .score(let scoreItem) = item {
                            VStack(alignment: .leading) {
                                Text("Score: \(scoreItem.league)")
                                    .font(.headline)
                                Text("\(scoreItem.teamA) vs \(scoreItem.teamB)")
                                Text("Start Time: \(formattedDate(scoreItem.startTime))")
                                Text("Info: \(scoreItem.additionalInfo)")
                            }
                        } else if case .news(let newsItem) = item {
                            Text("News: \(newsItem.text)")
                                .font(.headline)
                        }
                        Spacer()
                    }
                    .contentShape(Rectangle()) // Makes the entire row tappable
                    .onTapGesture {
                        selectedItem = item
                        showingEditItem = true
                    }
                    .contextMenu {
                        // Edit Option
                        Button(action: {
                            selectedItem = item
                            showingEditItem = true
                        }) {
                            Text("Edit")
                            Image(systemName: "pencil")
                        }
                        // Delete Option with Confirmation
                        Button(role: .destructive, action: {
                            itemToDelete = item
                            showingDeleteConfirmation = true
                        }) {
                            Text("Delete")
                            Image(systemName: "trash")
                        }
                    }
                    .onDrag {
                        NSItemProvider(object: item.id.uuidString as NSString)
                    }
                    .onDrop(of: [.text], delegate: ItemDropDelegate(item: item, viewModel: viewModel))
                }
                // Enables swipe-to-delete
                .onDelete(perform: viewModel.removeItem)
            }
            .listStyle(PlainListStyle())
            
            Divider()
            
            // Logo Display and Upload Button
            HStack {
                Text("Logo")
                    .font(.headline)
                Spacer()
                if let logo = viewModel.logo {
                    Image(nsImage: logo)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 50)
                        .cornerRadius(8)
                        .help("Current logo")
                } else {
                    Text("No Logo")
                        .foregroundColor(.gray)
                }
                Button(action: {
                    showingImagePicker = true
                }) {
                    Text("Upload Logo")
                }
                .help("Upload a new logo image")
            }
            .padding()
        }
        // Add Item Sheet
        .sheet(isPresented: $showingAddItem) {
            ItemEditorView(viewModel: viewModel, isPresented: $showingAddItem)
        }
        // Edit Item Sheet
        .sheet(item: $selectedItem) { item in
            ItemEditorView(viewModel: viewModel, isPresented: $showingEditItem, itemToEdit: item)
        }
        // Image Picker Sheet
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $viewModel.logo)
        }
        // Delete Confirmation Alert
        .alert(isPresented: $showingDeleteConfirmation) {
            Alert(
                title: Text("Delete Item"),
                message: Text("Are you sure you want to delete this item?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let item = itemToDelete {
                        viewModel.removeItem(item: item)
                        successMessage = "Item deleted successfully."
                        showingSuccessAlert = true
                        itemToDelete = nil
                    }
                },
                secondaryButton: .cancel {
                    itemToDelete = nil
                }
            )
        }
        // Success Alert
        .alert(isPresented: $showingSuccessAlert) {
            Alert(
                title: Text("Success"),
                message: Text(successMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    /// Formats the date for display.
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    /// DropDelegate to handle reordering via drag and drop
    struct ItemDropDelegate: DropDelegate {
        let item: TickerItem
        let viewModel: TickerViewModel
        
        func performDrop(info: DropInfo) -> Bool {
            guard let itemProvider = info.itemProviders(for: [.text]).first else {
                return false
            }
            
            itemProvider.loadItem(forTypeIdentifier: "public.text", options: nil) { (data, error) in
                if let data = data as? Data,
                   let idString = String(data: data, encoding: .utf8),
                   let uuid = UUID(uuidString: idString),
                   let sourceItem = viewModel.items.first(where: { $0.id == uuid }),
                   let sourceIndex = viewModel.items.firstIndex(of: sourceItem),
                   let destinationIndex = viewModel.items.firstIndex(of: item) {
                    
                    DispatchQueue.main.async {
                        viewModel.items.move(fromOffsets: IndexSet(integer: sourceIndex), toOffset: destinationIndex > sourceIndex ? destinationIndex + 1 : destinationIndex)
                    }
                }
            }
            
            return true
        }
        
        func dropEntered(info: DropInfo) {
            // Optional: Implement if needed
        }
        
        func dropUpdated(info: DropInfo) -> DropProposal? {
            return DropProposal(operation: .move)
        }
        
        func dropExited(info: DropInfo) {
            // Optional: Implement if needed
        }
    }
    
    struct ControlView_Previews: PreviewProvider {
        static var previews: some View {
            ControlView(viewModel: TickerViewModel())
        }
    }
}
