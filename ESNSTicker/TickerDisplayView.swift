//
//  TickerDisplayView.swift
//  ESNSTicker
//
//  Created by Cameron Tarbell on 9/30/24.
//

import SwiftUI
import Combine

struct TickerDisplayView: View {
    @ObservedObject var viewModel: TickerViewModel
    @State private var currentIndex: Int = 0
    @State private var showItem: Bool = false
    @State private var logoImage: Image? = nil
    @State private var timer: AnyCancellable?
    
    let displayDuration: Double = 5.0 // Duration each item is displayed in seconds
    let transitionDuration: Double = 1.0 // Duration of the fade transition
    
    var body: some View {
        HStack(spacing: 10) {
            // Logo remains static
            if let logo = logoImage {
                logo
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 80)
                    .padding(.leading, 10)
            }
            
            Spacer()
            
            // Content Area
            ZStack {
                // Fixed Background based on current item type
                if !viewModel.items.isEmpty {
                    switch viewModel.items[currentIndex] {
                    case .score(_):
                        Color.blue.opacity(0.8)
                            .cornerRadius(10)
                    case .news(_):
                        Color.gray.opacity(0.8)
                            .cornerRadius(10)
                    }
                } else {
                    Color.black.opacity(0.8)
                        .cornerRadius(10)
                }
                
                // Animated Content
                if !viewModel.items.isEmpty {
                    if isScoreItem(currentItem: viewModel.items[currentIndex]) {
                        // Score Item View
                        ScoreItemView(item: viewModel.items[currentIndex])
                            .opacity(showItem ? 1 : 0)
                            .animation(.easeInOut(duration: transitionDuration), value: showItem)
                    } else {
                        // News Item View with Marquee
                        NewsItemView(text: viewModel.items[currentIndex].getNewsText())
                            .opacity(showItem ? 1 : 0)
                            .animation(.easeInOut(duration: transitionDuration), value: showItem)
                    }
                } else {
                    // No Items Placeholder
                    Text("No Items")
                        .foregroundColor(.white)
                        .opacity(showItem ? 1 : 0)
                        .animation(.easeInOut(duration: transitionDuration), value: showItem)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
        .onAppear {
            setupLogo()
            startTicker()
        }
        .onDisappear {
            timer?.cancel()
        }
        .onChange(of: viewModel.items) { _ in
            // Reset ticker when items change
            currentIndex = 0
            showItem = false
            timer?.cancel()
            startTicker()
        }
    }
    
    /// Determines if the current item is a score item.
    func isScoreItem(currentItem: TickerItem) -> Bool {
        switch currentItem {
        case .score(_):
            return true
        case .news(_):
            return false
        }
    }
    
    /// Sets up the logo image if one is provided in the view model.
    func setupLogo() {
        if let nsImage = viewModel.logo {
            logoImage = Image(nsImage: nsImage)
        } else {
            logoImage = nil
        }
    }
    
    /// Starts the ticker timer to transition between items.
    func startTicker() {
        guard !viewModel.items.isEmpty else { return }
        showItem = true
        
        timer = Timer.publish(every: displayDuration + transitionDuration, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                withAnimation {
                    showItem = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + transitionDuration) {
                    // Ensure currentIndex stays within bounds after deletion
                    if currentIndex >= viewModel.items.count - 1 && viewModel.items.count > 0 {
                        currentIndex = 0
                    } else {
                        currentIndex = (currentIndex + 1) % viewModel.items.count
                    }
                    withAnimation {
                        showItem = true
                    }
                }
            }
    }
}

/// View for displaying Score Items with fixed separators and sections.
struct ScoreItemView: View {
    var item: TickerItem
    
    // Define fixed widths for each section
    let leagueWidth: CGFloat = 150
    let teamsWidth: CGFloat = 200
    let startTimeWidth: CGFloat = 150
    let additionalInfoWidth: CGFloat = 200
    
    var body: some View {
        if case .score(let scoreItem) = item {
            HStack(spacing: 0) {
                // League Name
                Text(scoreItem.league)
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: leagueWidth, alignment: .leading)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                // First Separator
                SeparatorView()
                
                // Team Names
                Text("\(scoreItem.teamA) vs \(scoreItem.teamB)")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: teamsWidth, alignment: .center)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                // Second Separator
                SeparatorView()
                
                // Start Time
                Text(formattedStartTime(scoreItem.startTime))
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .frame(width: startTimeWidth, alignment: .center)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                // Third Separator
                SeparatorView()
                
                // Additional Info
                Text(scoreItem.additionalInfo)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(width: additionalInfoWidth, alignment: .trailing)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .padding(.horizontal, 20)
        }
    }
    
    /// Formats the start time, displaying "Today at TIME" if the date is today.
    func formattedStartTime(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            let timeFormatter = DateFormatter()
            timeFormatter.timeStyle = .short
            return "Today at \(timeFormatter.string(from: date))"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
    }
}

/// View for displaying News Items with marquee scrolling.
struct NewsItemView: View {
    var text: String
    
    var body: some View {
        MarqueeText(text: text, font: .headline, foregroundColor: .white, backgroundColor: Color.gray.opacity(0.8))
            .padding(.horizontal, 20)
    }
}

/// View for marquee scrolling text.
struct MarqueeText: View {
    let text: String
    let font: Font
    let foregroundColor: Color
    let backgroundColor: Color
    
    @State private var textWidth: CGFloat = 0
    @State private var animate: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background remains fixed
                backgroundColor
                    .cornerRadius(10)
                
                if textWidth > geometry.size.width {
                    Text(text)
                        .font(font)
                        .foregroundColor(foregroundColor)
                        .fixedSize()
                        .offset(x: animate ? -textWidth : geometry.size.width)
                        .onAppear {
                            calculateWidth(in: geometry)
                            startAnimation(in: geometry)
                        }
                        .onChange(of: text) { _ in
                            calculateWidth(in: geometry)
                            startAnimation(in: geometry)
                        }
                } else {
                    Text(text)
                        .font(font)
                        .foregroundColor(foregroundColor)
                        .fixedSize()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
    
    /// Calculates the width of the text to determine if scrolling is necessary.
    func calculateWidth(in geometry: GeometryProxy) {
        let attributedString = NSAttributedString(string: text, attributes: [.font: NSFont.systemFont(ofSize: NSFont.systemFontSize)])
        let size = attributedString.size()
        textWidth = size.width
    }
    
    /// Starts the marquee animation if the text exceeds the available width.
    func startAnimation(in geometry: GeometryProxy) {
        guard textWidth > geometry.size.width else {
            // No need to animate if text fits within the view
            animate = false
            return
        }
        
        // Reset animation
        animate = false
        
        // Start animation after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(Animation.linear(duration: Double(textWidth / 50)).repeatForever(autoreverses: false)) {
                animate = true
            }
        }
    }
}

/// A simple view representing a separator.
struct SeparatorView: View {
    var body: some View {
        Text("|")
            .foregroundColor(.white)
            .frame(width: 10)
            .padding(.horizontal, 5)
    }
}

struct TickerDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        // Sample Data for Preview
        let viewModel = TickerViewModel()
        viewModel.items = [
            .score(ScoreItem(league: "NBA", teamA: "Lakers", teamB: "Warriors", startTime: Date(), additionalInfo: "Final Score: 102-99")),
            .score(ScoreItem(league: "NFL", teamA: "Patriots", teamB: "Dolphins", startTime: Calendar.current.date(byAdding: .day, value: 1, to: Date())!, additionalInfo: "Kickoff at 7 PM")),
            .news(NewsItem(text: "Breaking News: Major trade announced!")),
            .news(NewsItem(text: "Update: Weather forecast changes for the weekend."))
        ]
        viewModel.logo = NSImage(systemSymbolName: "sportscourt", accessibilityDescription: "Logo")
        
        return TickerDisplayView(viewModel: viewModel)
            .frame(height: 100)
    }
}
