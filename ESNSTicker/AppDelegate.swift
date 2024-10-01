//
//  AppDelegate.swift
//  ESNSTicker
//
//  Created by Cameron Tarbell on 9/30/24.
//

import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var controlWindow: NSWindow!
    var displayWindow: NSWindow!
    
    let viewModel = TickerViewModel()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create Control Window
        let controlView = ControlView(viewModel: viewModel)
        controlWindow = NSWindow(
            contentRect: NSRect(x: 100, y: 100, width: 500, height: 700),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered, defer: false)
        controlWindow.title = "Control Panel"
        controlWindow.contentView = NSHostingView(rootView: controlView)
        controlWindow.makeKeyAndOrderFront(nil)
        
        // Create Display Window
        let displayView = TickerDisplayView(viewModel: viewModel)
        displayWindow = NSWindow(
            contentRect: NSRect(x: 650, y: 100, width: 1200, height: 100),
            styleMask: [.borderless, .resizable],
            backing: .buffered, defer: false)
        displayWindow.title = "Ticker Display"
        displayWindow.isOpaque = false
        displayWindow.backgroundColor = NSColor.clear
        displayWindow.hasShadow = false
        displayWindow.level = .floating
        displayWindow.contentView = NSHostingView(rootView: displayView)
        displayWindow.makeKeyAndOrderFront(nil)
    }
}
