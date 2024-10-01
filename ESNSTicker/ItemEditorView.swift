//
//  ItemEditorView.swift
//  ESNSTicker
//
//  Created by Cameron Tarbell on 9/30/24.
//
// ItemEditorView.swift

import SwiftUI

struct ItemEditorView: View {
    @ObservedObject var viewModel: TickerViewModel
    @Binding var isPresented: Bool
    
    @State private var selectedType: EditorItemType = .news
    
    // For ScoreItem
    @State private var league: String = ""
    @State private var teamA: String = ""
    @State private var teamB: String = ""
    @State private var startTime: Date = Date()
    @State private var additionalInfo: String = ""
    
    // For NewsItem
    @State private var newsText: String = ""
    
    var itemToEdit: TickerItem? = nil
    
    enum EditorItemType: String, CaseIterable, Identifiable {
        case news = "News"
        case score = "Score"
        
        var id: String { self.rawValue }
    }
    
    var body: some View {
        VStack {
            Picker("Item Type", selection: $selectedType) {
                ForEach(EditorItemType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .disabled(itemToEdit != nil)
            
            if selectedType == .score {
                Form {
                    TextField("League", text: $league)
                    TextField("Team A", text: $teamA)
                    TextField("Team B", text: $teamB)
                    DatePicker("Start Time", selection: $startTime, displayedComponents: [.date, .hourAndMinute])
                    TextField("Additional Info", text: $additionalInfo)
                }
                .padding()
            } else {
                Form {
                    TextField("News Text", text: $newsText)
                }
                .padding()
            }
            
            Spacer()
            
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                Spacer()
                Button(itemToEdit == nil ? "Add" : "Save") {
                    if selectedType == .score {
                        let scoreItem = ScoreItem(league: league, teamA: teamA, teamB: teamB, startTime: startTime, additionalInfo: additionalInfo)
                        if let existingItem = itemToEdit, case .score = existingItem {
                            viewModel.updateItem(.score(scoreItem))
                        } else {
                            viewModel.addItem(.score(scoreItem))
                        }
                    } else {
                        let newsItem = NewsItem(text: newsText)
                        if let existingItem = itemToEdit, case .news = existingItem {
                            viewModel.updateItem(.news(newsItem))
                        } else {
                            viewModel.addItem(.news(newsItem))
                        }
                    }
                    isPresented = false
                }
                .disabled(selectedType == .score ? (league.isEmpty || teamA.isEmpty || teamB.isEmpty) : newsText.isEmpty)
            }
            .padding()
        }
        .onAppear {
            if let item = itemToEdit {
                switch item {
                case .score(let score):
                    selectedType = .score
                    league = score.league
                    teamA = score.teamA
                    teamB = score.teamB
                    startTime = score.startTime
                    additionalInfo = score.additionalInfo
                case .news(let news):
                    selectedType = .news
                    newsText = news.text
                }
            }
        }
    }
    
    struct ItemEditorView_Previews: PreviewProvider {
        static var previews: some View {
            ItemEditorView(viewModel: TickerViewModel(), isPresented: .constant(true))
        }
    }
}
