import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var userManager: UserManager
    @State private var username = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isNewUser = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Location Tracker")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 50)
                
                Text("Keep connected with your loved ones")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 50)
                
                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.never)
                    .padding(.horizontal)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.never)
                    .padding(.horizontal)
                
                Button(action: {
                    if userManager.login(username: username, password: password) {
                        userManager.isLoggedIn = true
                    } else {
                        alertMessage = "Invalid username or password"
                        showAlert = true
                    }
                }) {
                    Text("Login")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Button(action: {
                    userManager.isLoggedIn = true
                    userManager.isRegistered = false
                }) {
                    Text("New user? Create account")
                        .foregroundColor(.blue)
                }
                .padding()
                
                Spacer()
            }
            .padding()
            .alert("error", isPresented: $showAlert) {
                Button("ok", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
} 