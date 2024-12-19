import SwiftUI

struct PairingView: View {
    @State private var partnerCode = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Binding var isPaired: Bool
    @EnvironmentObject private var userManager: UserManager
    let currentUser: User
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Your Pairing Code")
                    .font(.headline)
                
                Text(currentUser.pairingCode)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2)))
                
                Text("Share this code with your partner")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Divider()
                    .padding(.vertical)
                
                Text("Enter Partner's Code")
                    .font(.headline)
                
                TextField("Enter 6-digit code", text: $partnerCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .frame(maxWidth: 200)
                    .multilineTextAlignment(.center)
                
                Button("Pair with Partner") {
                    validateAndPair()
                }
                .buttonStyle(.borderedProminent)
                .disabled(partnerCode.count != 6)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Pair with Partner")
            .alert("Pairing Status", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func validateAndPair() {
        if partnerCode == currentUser.pairingCode {
            alertMessage = "You cannot pair with yourself!"
            showAlert = true
            return
        }
        
        // For testing: accept "111111" as a valid partner code
        if partnerCode == "111111" {
            var updatedUser = currentUser
            updatedUser.partnerId = "TEST_PARTNER"
            userManager.currentUser = updatedUser
            userManager.saveUserData()  // Save the updated user data
            isPaired = true
            return
        }
        
        alertMessage = "Invalid pairing code. For testing, use: 111111"
        showAlert = true
    }
} 