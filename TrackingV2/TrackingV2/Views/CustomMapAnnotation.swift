import SwiftUI
import MapKit

struct UserAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let profileImage: UIImage
    let username: String
}

struct CustomMapAnnotation: View {
    let profileImage: UIImage
    let username: String
    
    var body: some View {
        VStack(spacing: 0) {
            // Profile picture in circle
            Image(uiImage: profileImage)
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                .shadow(radius: 3)
            
            // Triangle pointer
            Triangle()
                .fill(Color.accentColor)
                .frame(width: 20, height: 10)
                .offset(y: -5)
            
            // Username label
            Text(username)
                .font(.caption)
                .foregroundColor(.primary)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.white.opacity(0.8))
                .cornerRadius(4)
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
} 