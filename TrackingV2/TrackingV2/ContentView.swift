//
//  ContentView.swift
//  TrackingV2
//
//  Created by 宋鑫宇 on 2024-12-18.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var userManager: UserManager
    @StateObject private var permissionManager = PermissionManager()
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        ZStack {
            // Background color that transitions slowly
            (themeManager.isDarkMode ? Color.black : Color.white)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 2.0), value: themeManager.isDarkMode)
            
            // Content
            if !userManager.isLoggedIn {
                LoginView()
            } else if !userManager.isRegistered {
                RegistrationView { user in
                    userManager.currentUser = user
                    userManager.isRegistered = true
                    userManager.saveUserData()
                    permissionManager.requestAllPermissions()
                }
            } else if !userManager.isPaired {
                if let user = userManager.currentUser {
                    PairingView(isPaired: $userManager.isPaired, currentUser: user)
                }
            } else {
                MapView(currentUser: userManager.currentUser)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(UserManager.shared)
}
