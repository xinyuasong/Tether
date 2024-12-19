import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var userManager: UserManager
    @State private var username = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isNewUser = false
    @State private var rememberMe = false
    
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
                
                // Remember Me Toggle
                HStack {
                    Toggle(isOn: $rememberMe) {
                        Text("Remember Me")
                            .foregroundColor(.gray)
                    }
                    .toggleStyle(CheckboxToggleStyle())
                }
                .padding(.horizontal)
                
                Button(action: {
                    if userManager.login(username: username, password: password, rememberMe: rememberMe) {
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
            .alert("Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
}

// Custom Checkbox Toggle Style
struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .foregroundColor(configuration.isOn ? .blue : .gray)
                .font(.system(size: 20))
                .onTapGesture {
                    configuration.isOn.toggle()
                }
            configuration.label
        }
    }
} 