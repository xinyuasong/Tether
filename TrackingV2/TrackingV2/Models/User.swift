import Foundation
import UIKit
import CryptoKit

struct User: Codable {
    var id: String
    var username: String
    var birthday: Date
    var email: String
    var pairingCode: String
    var partnerId: String?
    var profileImageData: Data?
    var isEmailVerified: Bool
    private var hashedPassword: String
    
    init(id: String = UUID().uuidString, username: String, birthday: Date, email: String, password: String, profileImage: UIImage? = nil) {
        self.id = id
        self.username = username
        self.birthday = birthday
        self.email = email
        self.pairingCode = String(format: "%06d", Int.random(in: 100000...999999))
        self.partnerId = nil
        
        // Set default profile image if none provided
        if let customImage = profileImage {
            self.profileImageData = customImage.jpegData(compressionQuality: 0.7)
        } else {
            // Create default profile image with user's initials
            let initials = String(username.prefix(2)).uppercased()
            let defaultImage = User.generateInitialsImage(initials: initials)
            self.profileImageData = defaultImage.jpegData(compressionQuality: 1.0)
        }
        
        self.hashedPassword = User.hashPassword(password)
        self.isEmailVerified = false
    }
    
    // Generate default profile image with initials
    static func generateInitialsImage(initials: String) -> UIImage {
        let size = CGSize(width: 200, height: 200)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            // Draw circle background
            let colors = [
                UIColor(red: 0.4, green: 0.6, blue: 1.0, alpha: 1.0),
                UIColor(red: 0.3, green: 0.5, blue: 0.9, alpha: 1.0)
            ]
            
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors.map { $0.cgColor } as CFArray,
                locations: [0.0, 1.0]
            )!
            
            let circle = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            context.cgContext.addEllipse(in: circle)
            context.cgContext.clip()
            
            context.cgContext.drawLinearGradient(
                gradient,
                start: CGPoint(x: 0, y: 0),
                end: CGPoint(x: size.width, y: size.height),
                options: []
            )
            
            // Draw initials
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 80, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            
            let text = NSString(string: initials)
            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            
            text.draw(in: textRect, withAttributes: attributes)
        }
        
        return image
    }
    
    static func hashPassword(_ password: String) -> String {
        let salt = "your_salt_here"  // In production, use a proper salt strategy
        let saltedPassword = password + salt
        let hashedData = SHA256.hash(data: saltedPassword.data(using: .utf8)!)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    func verifyPassword(_ password: String) -> Bool {
        return self.hashedPassword == User.hashPassword(password)
    }
} 