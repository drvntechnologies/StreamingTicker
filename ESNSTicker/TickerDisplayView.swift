//
//  TickerDisplayView.swift
//  ESNSTicker
//
//  Created by Cameron Tarbell on 9/30/24.
//
// TickerDisplayView.swift

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
            // Logo on the left
            if let logo = logoImage {
                logo
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 80)
                    .padding(.leading, 10)
            }
            
            Spacer()
            
            // Ticker Item
            if !viewModel.items.isEmpty {
                if showItem {
                    TickerItemView(item: viewModel.items[currentIndex])
                        .transition(.opacity)
                        .animation(.easeInOut(duration: transitionDuration), value: showItem)
                }
            } else {
                Text("No Items")
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.7))
        .onAppear {
            setupLogo()
            startTicker()
        }
        .onDisappear {
            timer?.cancel()
        }
        .onChange(of: viewModel.items) { _ in
            currentIndex = 0
            showItem = false
            timer?.cancel()
            startTicker()
        }
    }
    
    func setupLogo() {
        if let nsImage = viewModel.logo {
            logoImage = Image(nsImage: nsImage)
        } else {
            logoImage = nil
        }
    }
    
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
                    currentIndex = (currentIndex + 1) % viewModel.items.count
                    withAnimation {
                        showItem = true
                    }
                }
            }
    }
}

struct TickerItemView: View {
    var item: TickerItem
    
    var body: some View {
        if case .score(let scoreItem) = item {
            HStack(spacing: 10) {
                Text(scoreItem.league)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("|")
                    .foregroundColor(.white)
                
                Text("\(scoreItem.teamA) vs \(scoreItem.teamB)")
                    .font(.title2)
                    .foregroundColor(.white)
                
                Text("|")
                    .foregroundColor(.white)
                
                Text("Start: \(formattedDate(scoreItem.startTime))")
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                Text("|")
                    .foregroundColor(.white)
                
                Text(scoreItem.additionalInfo)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.blue.opacity(0.8))
            .cornerRadius(10)
        } else if case .news(let newsItem) = item {
            Text(newsItem.text)
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.gray.opacity(0.8))
                .cornerRadius(10)
        }
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct TickerDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        TickerDisplayView(viewModel: TickerViewModel())
            .frame(height: 100)
    }
}
