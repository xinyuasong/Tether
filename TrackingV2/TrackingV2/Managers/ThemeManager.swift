import SwiftUI

class ThemeManager: ObservableObject {
    @AppStorage("isDarkMode") private(set) var isDarkMode: Bool = false
    
    static let shared = ThemeManager()
    
    private init() {}
    
    func toggleTheme() {
        isDarkMode.toggle()
    }
} 