import Foundation

@MainActor  // Ensure all operations happen on the main thread
class UserManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isRegistered: Bool = false
    @Published var isPaired: Bool = false
    @Published var isLoggedIn: Bool = false
    
    static let shared = UserManager()
    
    private init() {
        // Load user data and login state from UserDefaults
        loadUserData()
        loadLoginState()
    }
    
    func login(username: String, password: String, rememberMe: Bool = false) -> Bool {
        guard let savedUser = currentUser else { return false }
        if savedUser.username == username && savedUser.verifyPassword(password) {
            isLoggedIn = true
            isRegistered = true
            isPaired = savedUser.partnerId != nil
            
            if rememberMe {
                // Save login state if remember me is enabled
                saveLoginState()
            }
            return true
        }
        return false
    }
    
    func logout() {
        isLoggedIn = false
        isPaired = false
        // Clear remembered login state
        UserDefaults.standard.removeObject(forKey: "rememberedLogin")
    }
    
    private func loadUserData() {
        if let userData = UserDefaults.standard.data(forKey: "userData"),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            currentUser = user
            isRegistered = true
            isPaired = user.partnerId != nil
            print("DEBUG: Loaded user data - PartnerId: \(String(describing: user.partnerId))")
        }
    }
    
    private func loadLoginState() {
        if UserDefaults.standard.bool(forKey: "rememberedLogin") {
            isLoggedIn = true
        }
    }
    
    private func saveLoginState() {
        UserDefaults.standard.set(true, forKey: "rememberedLogin")
    }
    
    func saveUserData() {
        if let user = currentUser,
           let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: "userData")
            print("DEBUG: Saved user data - PartnerId: \(String(describing: user.partnerId))")
        }
    }
} 