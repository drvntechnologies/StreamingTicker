//
//  ESNSTickerApp.swift
//  ESNSTicker
//
//  Created by Cameron Tarbell on 9/30/24.
//

import SwiftUI

@main
struct ESNSTickerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // No main window; all windows are managed by AppDelegate
        Settings {
            EmptyView()
        }
    }
}
