//
//  ControlView.swift
//  ESNSTicker
//
//  Created by Cameron Tarbell on 9/30/24.
//
// ControlView.swift

import SwiftUI

struct ControlView: View {
    @ObservedObject var viewModel: TickerViewModel
    @State private var showingAddItem = false
    @State private var selectedItem: TickerItem? = nil
    @State private var showingEditItem = false
    @State private var showingImagePicker = false
    
    var body: some View {
        VStack {
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
            }
            .padding()
            
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
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedItem = item
                        showingEditItem = true
                    }
                    .contextMenu {
                        Button(action: {
                            selectedItem = item
                            showingEditItem = true
                        }) {
                            Text("Edit")
                            Image(systemName: "pencil")
                        }
                        Button(action: {
                            if let index = viewModel.items.firstIndex(where: { $0.id == item.id }) {
                                viewModel.items.remove(at: index)
                            }
                        }) {
                            Text("Delete")
                            Image(systemName: "trash")
                        }
                    }
                }
                .onDelete(perform: viewModel.removeItem)
                .onMove(perform: viewModel.moveItem)
            }
            .listStyle(PlainListStyle())
            
            Divider()
            
            HStack {
                Text("Logo")
                    .font(.headline)
                Spacer()
                if let logo = viewModel.logo {
                    Image(nsImage: logo)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 50)
                } else {
                    Text("No Logo")
                        .foregroundColor(.gray)
                }
                Button(action: {
                    showingImagePicker = true
                }) {
                    Text("Upload Logo")
                }
            }
            .padding()
        }
        .sheet(isPresented: $showingAddItem) {
            ItemEditorView(viewModel: viewModel, isPresented: $showingAddItem)
        }
        .sheet(item: $selectedItem) { item in
            ItemEditorView(viewModel: viewModel, isPresented: $showingEditItem, itemToEdit: item)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $viewModel.logo)
        }
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    struct ControlView_Previews: PreviewProvider {
        static var previews: some View {
            ControlView(viewModel: TickerViewModel())
        }
    }
}
