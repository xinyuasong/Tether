import SwiftUI

struct EmailVerificationView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var isVerified: Bool
    let email: String
    
    @State private var verificationCode = ""
    @State private var enteredCode = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var onVerificationComplete: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Verify Your Email")
                    .font(.title2)
                    .bold()
                
                Text("We've sent a verification code to:\n\(email)")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                
                Text("Enter the 6-digit code below")
                    .font(.subheadline)
                
                HStack(spacing: 12) {
                    ForEach(0..<6) { index in
                        let digit = index < enteredCode.count ? String(enteredCode[enteredCode.index(enteredCode.startIndex, offsetBy: index)]) : ""
                        
                        Text(digit)
                            .frame(width: 45, height: 45)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .multilineTextAlignment(.center)
                            .font(.title2.bold())
                    }
                }
                
                TextField("Enter verification code", text: $enteredCode)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(maxWidth: 200)
                    .multilineTextAlignment(.center)
                    .onChange(of: enteredCode) { oldValue, newValue in
                        // Limit to 6 digits
                        if newValue.count > 6 {
                            enteredCode = String(newValue.prefix(6))
                        }
                        // Keep only numbers
                        enteredCode = newValue.filter { $0.isNumber }
                    }
                
                Button("Verify") {
                    verifyCode()
                }
                .buttonStyle(.borderedProminent)
                .disabled(enteredCode.count != 6)
                
                Button("Resend Code") {
                    sendVerificationCode()
                }
                .padding(.top)
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert(alertMessage, isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            }
            .onAppear {
                sendVerificationCode()
            }
        }
    }
    
    private func sendVerificationCode() {
        // Fixed verification code for testing
        verificationCode = "111111"
        
        // For testing purposes
        print("Test verification code: 111111")
        
        alertMessage = "Verification code sent to \(email)\nUse 111111 for testing"
        showAlert = true
    }
    
    private func verifyCode() {
        if enteredCode == verificationCode {
            isVerified = true
            onVerificationComplete()
            dismiss()
        } else {
            alertMessage = "Invalid verification code. Please try again."
            showAlert = true
        }
    }
} 