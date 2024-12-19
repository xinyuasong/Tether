import Foundation

@MainActor  // Ensure all operations happen on the main thread
class UserManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isRegistered: Bool = false
    @Published var isPaired: Bool = false
    @Published var isLoggedIn: Bool = false
    
    static let shared = UserManager()
    
    private init() {
        // Load user data from UserDefaults if available
        loadUserData()
    }
    
    func login(username: String, password: String) -> Bool {
        guard let savedUser = currentUser else { return false }
        if savedUser.username == username && savedUser.verifyPassword(password) {
            isLoggedIn = true
            isRegistered = true
            isPaired = savedUser.partnerId != nil
            return true
        }
        return false
    }
    
    func logout() {
        isLoggedIn = false
        isPaired = false
    }
    
    private func loadUserData() {
        // In a real app, you would load from Keychain or secure storage
        if let userData = UserDefaults.standard.data(forKey: "userData"),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            currentUser = user
            isRegistered = true
            isPaired = user.partnerId != nil
            print("DEBUG: Loaded user data - PartnerId: \(String(describing: user.partnerId))")
        }
    }
    
    func saveUserData() {
        // In a real app, you would save to Keychain or secure storage
        if let user = currentUser,
           let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: "userData")
            print("DEBUG: Saved user data - PartnerId: \(String(describing: user.partnerId))")
        }
    }
} 