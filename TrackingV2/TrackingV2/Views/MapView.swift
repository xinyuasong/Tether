import SwiftUI
import MapKit

// MARK: - Models
struct SimulatedPartner {
    let coordinate: CLLocationCoordinate2D
    let username: String
    let profileImage: UIImage
    let deviceInfo: DeviceInfo
    
    static let shared = SimulatedPartner(
        coordinate: CLLocationCoordinate2D(latitude: 43.6532, longitude: -79.3832),
        username: "Vicky",
        profileImage: User.generateInitialsImage(initials: "VI"),
        deviceInfo: DeviceInfo(
            deviceName: "Vicky's iPhone 15 Pro",
            wifiName: "Home-WiFi",
            batteryLevel: 72,
            isCharging: true
        )
    )
}

struct DeviceInfo {
    let deviceName: String
    let wifiName: String
    let batteryLevel: Int
    let isCharging: Bool
}

struct LocationHistoryAnnotation: Identifiable {
    let id: Int
    let coordinate: CLLocationCoordinate2D
    let isCurrentLocation: Bool
    let stayDuration: TimeInterval // Duration in seconds
    let timestamp: Date
}

// Add this struct for phone usage data
struct PhoneUsageData {
    let screenTimeHours: Double
    let unlockCount: Int
    let lastUnlockTime: Date
    
    static let sample = PhoneUsageData(
        screenTimeHours: 5.5, // 5 hours and 30 minutes
        unlockCount: 47,
        lastUnlockTime: Date().addingTimeInterval(-1800) // 30 minutes ago
    )
}

// MARK: - Views
struct CircularProgressView: View {
    let progress: Double // 0.0 to 1.0
    let size: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 10)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.orange, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
            
            VStack {
                Text("\(Int(progress * 24))h")
                    .font(.system(size: size * 0.25, weight: .bold))
                Text("\(Int((progress * 24 * 60).truncatingRemainder(dividingBy: 60)))m")
                    .font(.system(size: size * 0.15))
                    .foregroundColor(.gray)
            }
        }
        .frame(width: size, height: size)
    }
}

struct BottomSheetView: View {
    @Binding var isExpanded: Bool
    let distance: Double
    let partnerName: String
    let deviceInfo: DeviceInfo
    @State private var partnerAddress: String = "Loading address..."
    @State private var scrollLevel: Int = 0 // 0: collapsed, 1: partial, 2: full
    
    // Sample phone usage data
    private let phoneUsage = PhoneUsageData.sample
    
    private let geocoder = CLGeocoder()
    
    // Simulated location history for demo with stay durations
    private let locationHistory: [LocationHistoryAnnotation] = [
        LocationHistoryAnnotation(
            id: 0,
            coordinate: CLLocationCoordinate2D(latitude: 43.6532, longitude: -79.3832),
            isCurrentLocation: true,
            stayDuration: 3600, // 1 hour
            timestamp: Date()
        ),
        LocationHistoryAnnotation(
            id: 1,
            coordinate: CLLocationCoordinate2D(latitude: 43.6547, longitude: -79.3845),
            isCurrentLocation: false,
            stayDuration: 1200, // 20 minutes (coffee shop)
            timestamp: Date().addingTimeInterval(-7200)
        ),
        LocationHistoryAnnotation(
            id: 2,
            coordinate: CLLocationCoordinate2D(latitude: 43.6520, longitude: -79.3810),
            isCurrentLocation: false,
            stayDuration: 3600, // 1 hour (park)
            timestamp: Date().addingTimeInterval(-14400)
        ),
        LocationHistoryAnnotation(
            id: 3,
            coordinate: CLLocationCoordinate2D(latitude: 43.6540, longitude: -79.3820),
            isCurrentLocation: false,
            stayDuration: 600, // 10 minutes (passing by)
            timestamp: Date().addingTimeInterval(-18000)
        )
    ]
    
    // Break down location history processing
    private var significantPlaces: [LocationHistoryAnnotation] {
        return locationHistory.filter { location in
            let isSignificant = location.stayDuration >= 900 // 15 minutes
            return isSignificant
        }
    }
    
    private func formatStayDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration / 60)
        return "\(minutes) minutes"
    }
    
    private func formatTimeAgo(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        let hours = Int(interval / 3600)
        let minutes = Int((interval.truncatingRemainder(dividingBy: 3600)) / 60)
        return "\(hours)h \(minutes)m ago"
    }
    
    private func createLocationListItem(for place: LocationHistoryAnnotation) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.orange.opacity(0.6))
                .frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 4) {
                Text("Stayed for \(formatStayDuration(place.stayDuration))")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Text(formatTimeAgo(from: place.timestamp))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
    
    private func createLocationAnnotation(for annotation: LocationHistoryAnnotation) -> some View {
        VStack(spacing: 4) {
            Circle()
                .fill(annotation.isCurrentLocation ? Color.orange : Color.gray)
                .frame(width: 12, height: 12)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
            if !annotation.isCurrentLocation {
                Text("\(Int(annotation.stayDuration/60))m")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 4)
                    .background(Color.white)
                    .cornerRadius(4)
            }
        }
    }
    
    private var locationHistorySection: some View {
        VStack(spacing: 20) {
            Text("\(partnerName) has been to \(significantPlaces.count) places today")
                .font(.title3.bold())
                .padding(.top, 10)
            
            locationHistoryMap
            locationHistoryList
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.95))
                .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
    
    private var locationHistoryMap: some View {
        Map(coordinateRegion: .constant(MKCoordinateRegion(
            center: locationHistory[0].coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )), annotationItems: significantPlaces) { annotation in
            MapAnnotation(coordinate: annotation.coordinate) {
                createLocationAnnotation(for: annotation)
            }
        }
        .frame(height: 300)
        .cornerRadius(15)
    }
    
    private var locationHistoryList: some View {
        VStack(alignment: .leading, spacing: 15) {
            ForEach(significantPlaces.filter { !$0.isCurrentLocation }) { place in
                createLocationListItem(for: place)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 15)
    }
    
    private var phoneUsageSection: some View {
        VStack(spacing: 20) {
            Text("\(partnerName)'s phone report for today")
                .font(.title3.bold())
                .padding(.top)
            
            VStack(spacing: 15) {
                CircularProgressView(
                    progress: phoneUsage.screenTimeHours / 24,
                    size: 120
                )
                
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "lock.rotation")
                            .foregroundColor(.orange)
                        Text("Unlocked \(phoneUsage.unlockCount) times today")
                    }
                    
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.orange)
                        Text("Last unlocked \(formatTimeAgo(from: phoneUsage.lastUnlockTime))")
                    }
                }
                .font(.subheadline)
            }
            .padding(.vertical)
        }
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.95))
                .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
    
    private var sectionSeparator: some View {
        HStack {
            Rectangle()
                .fill(Color.orange.opacity(0.3))
                .frame(height: 1)
            Image(systemName: "location.circle.fill")
                .foregroundColor(.orange)
                .font(.title2)
            Rectangle()
                .fill(Color.orange.opacity(0.3))
                .frame(height: 1)
        }
        .padding(.horizontal)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Drag Indicator
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.gray.opacity(0.5))
                .frame(width: 40, height: 5)
                .padding(.vertical, 8)
            
            if scrollLevel == 1 {
                // First expanded level
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(partnerName)
                                .font(.title2.bold())
                            Spacer()
                        }
                        
                        // Device Information
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "iphone.gen3")
                                    .foregroundColor(.orange)
                                Text(deviceInfo.deviceName)
                            }
                            
                            HStack {
                                Image(systemName: "wifi")
                                    .foregroundColor(.orange)
                                Text(deviceInfo.wifiName)
                            }
                            
                            HStack {
                                Image(systemName: deviceInfo.isCharging ? "battery.100.bolt" : "battery.75")
                                    .foregroundColor(deviceInfo.isCharging ? .green : (deviceInfo.batteryLevel < 20 ? .red : .orange))
                                Text("\(deviceInfo.batteryLevel)%")
                                if deviceInfo.isCharging {
                                    Text("Charging")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                        
                        Divider()
                        
                        // Location Details
                        VStack(alignment: .leading, spacing: 8) {
                            Text(partnerAddress)
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            
            if scrollLevel == 2 {
                // Second expanded level (Full screen)
                GeometryReader { geometry in
                    ScrollView {
                        VStack(spacing: 30) {
                            phoneUsageSection
                            sectionSeparator
                            locationHistorySection
                            
                            // Add extra padding at the bottom
                            Color.clear.frame(height: 100)
                        }
                        .padding(.vertical)
                        .frame(minHeight: geometry.size.height)
                    }
                }
                .background(
                    Color.orange.opacity(0.2)
                        .overlay(
                            Color.white.opacity(0.3)
                        )
                )
                .edgesIgnoringSafeArea(.all)
            }
            
            // Always visible content (distance)
            if scrollLevel < 2 {
                HStack {
                    Image(systemName: "arrow.left.and.right")
                        .font(.title2)
                    Text(String(format: "%.1f", distance))
                        .font(.system(size: 34, weight: .bold))
                    Text("kilometers apart")
                        .font(.title3)
                }
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(Color.white.opacity(0.95))
            }
        }
        .background(scrollLevel == 2 ? Color.orange.opacity(0.05) : Color.white)
        .mask(
            RoundedRectangle(cornerRadius: scrollLevel == 2 ? 0 : 15)
                .padding(.bottom, scrollLevel == 2 ? 0 : -100)
        )
        .edgesIgnoringSafeArea(.all)
        .frame(maxWidth: .infinity, maxHeight: scrollLevel == 2 ? UIScreen.main.bounds.height : nil)
        .shadow(radius: scrollLevel == 2 ? 0 : 10)
        .gesture(
            DragGesture(minimumDistance: scrollLevel == 2 ? 0 : 50)
                .onEnded { gesture in
                    let threshold: CGFloat = 50
                    if gesture.translation.height < -threshold {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            scrollLevel = min(scrollLevel + 1, 2)
                        }
                    } else if gesture.translation.height > threshold {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            scrollLevel = max(scrollLevel - 1, 0)
                        }
                    }
                }
        )
        .onChange(of: scrollLevel) { oldValue, newValue in
            if newValue >= 1 {
                // Get address when expanded
                let location = CLLocation(
                    latitude: SimulatedPartner.shared.coordinate.latitude,
                    longitude: SimulatedPartner.shared.coordinate.longitude
                )
                geocoder.reverseGeocodeLocation(location) { placemarks, error in
                    if let placemark = placemarks?.first {
                        let address = [
                            placemark.subThoroughfare,
                            placemark.thoroughfare,
                            placemark.locality,
                            placemark.administrativeArea,
                            placemark.postalCode,
                            placemark.country
                        ].compactMap { $0 }.joined(separator: ", ")
                        
                        DispatchQueue.main.async {
                            partnerAddress = address
                        }
                    }
                }
            }
        }
    }
}

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    @EnvironmentObject private var userManager: UserManager
    let currentUser: User?
    
    @State private var zoomLevel: Double = 1.5
    @State private var isBottomSheetExpanded = false
    
    private var distanceInKilometers: Double? {
        guard let userLocation = locationManager.userLocation,
              let partner = partnerAnnotation else {
            return nil
        }
        
        let distance = userLocation.distance(from: CLLocation(
            latitude: partner.coordinate.latitude,
            longitude: partner.coordinate.longitude
        )) / 1000.0 // Convert meters to kilometers
        
        return distance
    }
    
    var userAnnotation: UserAnnotation? {
        guard let location = locationManager.userLocation,
              let user = currentUser,
              let imageData = user.profileImageData,
              let image = UIImage(data: imageData) else {
            return nil
        }
        
        return UserAnnotation(
            coordinate: location.coordinate,
            profileImage: image,
            username: user.username
        )
    }
    
    var partnerAnnotation: UserAnnotation? {
        // Only show partner if the current user is paired with TEST_PARTNER
        guard let user = currentUser, user.partnerId == "TEST_PARTNER" else {
            print("DEBUG: Partner not showing because - User: \(String(describing: currentUser)), PartnerId: \(String(describing: currentUser?.partnerId))")
            return nil
        }
        
        print("DEBUG: Creating partner annotation for Vicky in Toronto")
        return UserAnnotation(
            coordinate: SimulatedPartner.shared.coordinate,
            profileImage: SimulatedPartner.shared.profileImage,
            username: SimulatedPartner.shared.username
        )
    }
    
    var body: some View {
        ZStack {
            // Map View
            Map(coordinateRegion: .constant(locationManager.region), annotationItems: [userAnnotation, partnerAnnotation].compactMap { $0 }) { annotation in
                MapAnnotation(coordinate: annotation.coordinate) {
                    CustomMapAnnotation(
                        profileImage: annotation.profileImage,
                        username: annotation.username
                    )
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
                MapPitchToggle()
            }
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        let zoomDelta = (value - 1.0) * 0.5
                        zoomLevel = max(0.005, min(1.0, zoomLevel - zoomDelta))
                        updateRegion()
                    }
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                HStack {
                    // Find Vicky Button (Heart Icon)
                    Button(action: {
                        if let partner = partnerAnnotation {
                            withAnimation {
                                let region = MKCoordinateRegion(
                                    center: partner.coordinate,
                                    span: MKCoordinateSpan(
                                        latitudeDelta: zoomLevel,
                                        longitudeDelta: zoomLevel
                                    )
                                )
                                locationManager.region = region
                            }
                        }
                    }) {
                        Image(systemName: "heart.circle.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.pink)
                            .background(Color.white.opacity(0.9))
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                    
                    Spacer()
                    
                    // Refresh Button
                    Button(action: {
                        withAnimation {
                            locationManager.requestLocationPermission()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.blue)
                            .background(Color.white.opacity(0.9))
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
                
                // Bottom Sheet
                if let distance = distanceInKilometers {
                    BottomSheetView(
                        isExpanded: $isBottomSheetExpanded,
                        distance: distance,
                        partnerName: partnerAnnotation?.username ?? "Partner",
                        deviceInfo: SimulatedPartner.shared.deviceInfo
                    )
                }
            }
            
            if let error = locationManager.locationError {
                VStack {
                    Text(error)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(8)
                    
                    Button("Open Settings") {
                        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsUrl)
                        }
                    }
                    .padding()
                }
                .padding()
            }
        }
        .onAppear {
            locationManager.requestLocationPermission()
        }
        .onChange(of: locationManager.userLocation) { oldValue, newLocation in
            if let location = newLocation {
                withAnimation {
                    let region = MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(
                            latitudeDelta: zoomLevel,
                            longitudeDelta: zoomLevel
                        )
                    )
                    locationManager.region = region
                }
            }
        }
    }
    
    private func zoomIn() {
        withAnimation {
            zoomLevel = max(0.005, zoomLevel * 0.5)
            updateRegion()
        }
    }
    
    private func zoomOut() {
        withAnimation {
            zoomLevel = min(1.0, zoomLevel * 2.0)
            updateRegion()
        }
    }
    
    private func updateRegion() {
        if let coordinate = userAnnotation?.coordinate {
            let region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(
                    latitudeDelta: zoomLevel,
                    longitudeDelta: zoomLevel
                )
            )
            locationManager.region = region
        }
    }
} 