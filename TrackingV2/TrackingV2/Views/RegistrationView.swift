import SwiftUI
import PhotosUI

struct RegistrationView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var birthday = Date()
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var showEmailVerification = false
    @State private var isEmailVerified = false
    @State private var showDatePicker = false
    
    private let birthdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()
    
    var onRegisterComplete: (User) -> Void
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func validateInputs() -> Bool {
        if username.isEmpty {
            alertMessage = "please enter a username"
            showAlert = true
            return false
        }
        if email.isEmpty {
            alertMessage = "please enter an email"
            showAlert = true
            return false
        }
        if !isValidEmail(email) {
            alertMessage = "please enter a valid email address"
            showAlert = true
            return false
        }
        if !isEmailVerified {
            alertMessage = "please verify your email"
            showAlert = true
            return false
        }
        if password.isEmpty {
            alertMessage = "please enter a password"
            showAlert = true
            return false
        }
        if password.count < 6 {
            alertMessage = "password must be at least 6 characters"
            showAlert = true
            return false
        }
        if password != confirmPassword {
            alertMessage = "passwords do not match"
            showAlert = true
            return false
        }
        return true
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Form {
                    Section(header: Text("Profile Picture")) {
                        HStack {
                            Spacer()
                            Button(action: {
                                showImagePicker = true
                            }) {
                                if let image = selectedImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                        .foregroundColor(.gray)
                                }
                            }
                            Spacer()
                        }
                        .listRowBackground(Color.clear)
                    }
                    
                    Section(header: Text("Personal Information")) {
                        TextField("Username", text: $username)
                            .textInputAutocapitalization(.never)
                        HStack {
                            TextField("Email", text: $email)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .autocorrectionDisabled(true)
                            if !email.isEmpty && !isEmailVerified {
                                Button("Verify") {
                                    if isValidEmail(email) {
                                        showEmailVerification = true
                                    } else {
                                        alertMessage = "Please enter a valid email address"
                                        showAlert = true
                                    }
                                }
                                .foregroundColor(.blue)
                            }
                            if isEmailVerified {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        SecureField("Password", text: $password)
                            .textInputAutocapitalization(.never)
                        SecureField("Confirm Password", text: $confirmPassword)
                            .textInputAutocapitalization(.never)
                        
                        // Custom Birthday Picker
                        HStack {
                            Text("Birthday")
                            Spacer()
                            Button(action: {
                                showDatePicker.toggle()
                            }) {
                                Text(birthdayFormatter.string(from: birthday))
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    
                    Section {
                        Button("Register") {
                            if validateInputs() {
                                let user = User(
                                    id: UUID().uuidString,
                                    username: username,
                                    birthday: birthday,
                                    email: email,
                                    password: password,
                                    profileImage: selectedImage
                                )
                                onRegisterComplete(user)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .buttonStyle(.borderedProminent)
                        .disabled(!isEmailVerified)
                    }
                }
                .navigationTitle("Registration")
                .alert("Error", isPresented: $showAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(alertMessage)
                }
                
                // Theme toggle button
                VStack {
                    Spacer()
                    Button(action: {
                        themeManager.toggleTheme()
                    }) {
                        HStack {
                            Image(systemName: themeManager.isDarkMode ? "moon.fill" : "sun.max.fill")
                                .imageScale(.large)
                                .rotationEffect(.degrees(themeManager.isDarkMode ? 360 : 0))
                                .animation(.spring(response: 0.3), value: themeManager.isDarkMode)
                            Text(themeManager.isDarkMode ? "Dark Mode" : "Light Mode")
                                .opacity(0.9)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.accentColor.opacity(0.9))
                        )
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                    }
                    .padding(.bottom, 20)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
            .sheet(isPresented: $showEmailVerification) {
                EmailVerificationView(
                    isVerified: $isEmailVerified,
                    email: email,
                    onVerificationComplete: {
                        // Handle successful verification
                    }
                )
            }
            .sheet(isPresented: $showDatePicker) {
                NavigationView {
                    VStack {
                        DatePicker("", selection: $birthday, displayedComponents: [.date])
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                    }
                    .navigationTitle("Select Birthday")
                    .navigationBarItems(
                        trailing: Button("Done") {
                            showDatePicker = false
                        }
                    )
                }
                .presentationDetents([.height(300)])
            }
            .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
            .transition(.opacity)
        }
    }
}

// Image Picker using PhotosUI
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image as? UIImage
                    }
                }
            }
        }
    }
} 