//
//  TrackingV2App.swift
//  TrackingV2
//
//  Created by 宋鑫宇 on 2024-12-18.
//

import SwiftUI

@main
struct TrackingV2App: App {
    @StateObject private var userManager = UserManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userManager)
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
        }
    }
}
