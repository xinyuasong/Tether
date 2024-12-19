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
    let address: String
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

// Add this struct for call records
struct CallRecord: Identifiable {
    let id = UUID()
    let phoneNumber: String
    let duration: TimeInterval
    let timestamp: Date
    let contactName: String?
    
    // Sample data
    static let sampleRecords = [
        CallRecord(
            phoneNumber: "+1 (647) 555-0123",
            duration: 183, // 3 minutes 3 seconds
            timestamp: Date().addingTimeInterval(-1800), // 30 minutes ago
            contactName: "Mom"
        ),
        CallRecord(
            phoneNumber: "+1 (416) 555-0189",
            duration: 425, // 7 minutes 5 seconds
            timestamp: Date().addingTimeInterval(-7200), // 2 hours ago
            contactName: "John"
        ),
        CallRecord(
            phoneNumber: "+1 (905) 555-0147",
            duration: 62, // 1 minute 2 seconds
            timestamp: Date().addingTimeInterval(-18000), // 5 hours ago
            contactName: "Pizza Place"
        ),
        CallRecord(
            phoneNumber: "+1 (647) 555-0123",
            duration: 305, // 5 minutes 5 seconds
            timestamp: Date().addingTimeInterval(-28800), // 8 hours ago
            contactName: "Mom"
        ),
        CallRecord(
            phoneNumber: "+1 (416) 555-0167",
            duration: 183, // 3 minutes 3 seconds
            timestamp: Date().addingTimeInterval(-36000), // 10 hours ago
            contactName: "Sarah"
        ),
        CallRecord(
            phoneNumber: "+1 (905) 555-0198",
            duration: 242, // 4 minutes 2 seconds
            timestamp: Date().addingTimeInterval(-43200), // 12 hours ago
            contactName: "Work"
        ),
        CallRecord(
            phoneNumber: "+1 (647) 555-0145",
            duration: 125, // 2 minutes 5 seconds
            timestamp: Date().addingTimeInterval(-50400), // 14 hours ago
            contactName: "David"
        )
    ]
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
    @State private var showingMoreCalls = false
    @State private var showingCallHistory = false
    @State private var showingMorePlaces = false
    @State private var showingPlacesHistory = false
    
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
            timestamp: Date(),
            address: "200 Bay Street, Toronto, ON"
        ),
        LocationHistoryAnnotation(
            id: 1,
            coordinate: CLLocationCoordinate2D(latitude: 43.6547, longitude: -79.3845),
            isCurrentLocation: false,
            stayDuration: 1200, // 20 minutes
            timestamp: Date().addingTimeInterval(-7200),
            address: "Tim Hortons, 382 Yonge St, Toronto, ON"
        ),
        LocationHistoryAnnotation(
            id: 2,
            coordinate: CLLocationCoordinate2D(latitude: 43.6520, longitude: -79.3810),
            isCurrentLocation: false,
            stayDuration: 3600, // 1 hour
            timestamp: Date().addingTimeInterval(-14400),
            address: "Trinity Square Park, Toronto, ON"
        ),
        LocationHistoryAnnotation(
            id: 3,
            coordinate: CLLocationCoordinate2D(latitude: 43.6540, longitude: -79.3820),
            isCurrentLocation: false,
            stayDuration: 600, // 10 minutes
            timestamp: Date().addingTimeInterval(-18000),
            address: "CF Toronto Eaton Centre"
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
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.orange.opacity(0.6))
                    .frame(width: 8, height: 8)
                Text(place.address)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            
            HStack {
                Text("Stayed for \(formatStayDuration(place.stayDuration))")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Text(formatTimeAgo(from: place.timestamp))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.leading, 20)
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
    
    private func sectionHeader(icon: String, color: Color = .orange) -> some View {
        HStack {
            Rectangle()
                .fill(color.opacity(0.4))
                .frame(height: 2)
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
            Rectangle()
                .fill(color.opacity(0.4))
                .frame(height: 2)
        }
    }
    
    private var locationHistorySection: some View {
        VStack(spacing: 0) {
            sectionHeader(icon: "location.circle.fill")
                .padding(.horizontal)
                .padding(.vertical, 15)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white.opacity(0.95))
                )
            
            VStack(spacing: 15) {
                Text("Places Visited")
                    .font(.title.bold())
                    .foregroundColor(.orange)
                    .padding(.top, 5)
                
                Text("\(partnerName) has been to \(significantPlaces.count) locations")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                locationHistoryMap
                locationHistoryList
            }
            .padding(.vertical, 10)
            .padding(.horizontal)
            .background(Color.white.opacity(0.95))
        }
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.95))
                .shadow(color: Color.orange.opacity(0.2), radius: 8, x: 0, y: 4)
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
            ForEach(significantPlaces.filter { !$0.isCurrentLocation }.prefix(3)) { place in
                createLocationListItem(for: place)
            }
            
            if significantPlaces.count > 3 {
                Button(action: {
                    showingPlacesHistory.toggle()
                }) {
                    Text("More")
                        .foregroundColor(.orange)
                        .font(.system(size: 14, weight: .medium))
                }
                .padding(.top, 2)
                .sheet(isPresented: $showingPlacesHistory) {
                    PlacesHistoryView(partnerName: partnerName, locationHistory: locationHistory)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 15)
    }
    
    private var phoneAndCallsRow: some View {
        HStack(spacing: 15) {
            // Phone Usage Section (Left)
            VStack(spacing: 0) {
                sectionHeader(icon: "iphone.circle.fill")
                    .padding(.horizontal)
                    .padding(.vertical, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white.opacity(0.95))
                    )
                
                VStack(spacing: 12) {
                    Text("Phone Report")
                        .font(.title3.bold())
                        .foregroundColor(.orange)
                    
                    CircularProgressView(
                        progress: phoneUsage.screenTimeHours / 24,
                        size: 100
                    )
                    .padding(.vertical, 5)
                    
                    VStack(spacing: 12) {
                        deviceInfoRow(
                            icon: "lock.rotation",
                            text: "\(phoneUsage.unlockCount) unlocks",
                            color: .orange
                        )
                        
                        deviceInfoRow(
                            icon: "clock",
                            text: formatTimeAgo(from: phoneUsage.lastUnlockTime),
                            color: .orange
                        )
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal)
                .background(Color.white.opacity(0.95))
            }
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white.opacity(0.95))
                    .shadow(color: Color.orange.opacity(0.2), radius: 8, x: 0, y: 4)
            )
            
            // Call Records Section (Right)
            VStack(spacing: 0) {
                sectionHeader(icon: "phone.circle.fill", color: .green)
                    .padding(.horizontal)
                    .padding(.vertical, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white.opacity(0.95))
                    )
                
                VStack(spacing: 12) {
                    Text("Call Records")
                        .font(.title3.bold())
                        .foregroundColor(.orange)
                    
                    VStack(spacing: 8) {
                        ForEach(Array(CallRecord.sampleRecords.prefix(showingMoreCalls ? 7 : 3))) { record in
                            HStack {
                                Image(systemName: "phone.fill")
                                    .foregroundColor(.green)
                                    .font(.system(size: 16))
                                    .frame(width: 20)
                                
                                Text(record.contactName ?? record.phoneNumber)
                                    .font(.system(size: 14, weight: .medium))
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(formatTimeAgo(from: record.timestamp))
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                    Text(formatCallDuration(record.duration))
                                        .font(.caption2)
                                        .foregroundColor(.green)
                                }
                            }
                            .padding(.vertical, 4)
                            
                            if showingMoreCalls || CallRecord.sampleRecords.prefix(3).contains { $0.id == record.id } {
                                Divider()
                            }
                        }
                        
                        Button(action: {
                            showingCallHistory.toggle()
                        }) {
                            Text("More")
                                .foregroundColor(.orange)
                                .font(.system(size: 14, weight: .medium))
                        }
                        .padding(.top, 2)
                        .sheet(isPresented: $showingCallHistory) {
                            CallHistoryView(partnerName: partnerName)
                        }
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal)
                .background(Color.white.opacity(0.95))
            }
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white.opacity(0.95))
                    .shadow(color: Color.orange.opacity(0.2), radius: 8, x: 0, y: 4)
            )
        }
        .padding(.horizontal)
    }
    
    private var partnerDetailsSection: some View {
        VStack(spacing: 0) {
            sectionHeader(icon: "person.circle.fill")
                .padding(.horizontal)
                .padding(.vertical, 15)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white.opacity(0.95))
                )
            
            VStack(spacing: 15) {
                Text(partnerName)
                    .font(.title.bold())
                    .foregroundColor(.orange)
                    .padding(.top, 5)
                
                Text("Device Information")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                // Device Information
                VStack(spacing: 15) {
                    deviceInfoRow(
                        icon: "iphone.gen3",
                        text: deviceInfo.deviceName,
                        color: .orange
                    )
                    
                    deviceInfoRow(
                        icon: "wifi",
                        text: deviceInfo.wifiName,
                        color: .orange
                    )
                    
                    deviceInfoRow(
                        icon: deviceInfo.isCharging ? "battery.100.bolt" : "battery.75",
                        text: "\(deviceInfo.batteryLevel)%",
                        color: deviceInfo.isCharging ? .green : (deviceInfo.batteryLevel < 20 ? .red : .orange),
                        additionalText: deviceInfo.isCharging ? "Charging" : nil,
                        additionalTextColor: .green
                    )
                }
                .padding(.vertical, 5)
                
                Divider()
                    .padding(.horizontal)
                
                // Location Details
                VStack(spacing: 10) {
                    Text("Current Location")
                        .font(.headline)
                        .foregroundColor(.orange)
                    
                    Text(partnerAddress)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 5)
            }
            .padding(.vertical, 10)
            .padding(.horizontal)
            .background(Color.white.opacity(0.95))
        }
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.95))
                .shadow(color: Color.orange.opacity(0.2), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal)
    }
    
    private func deviceInfoRow(icon: String, text: String, color: Color, additionalText: String? = nil, additionalTextColor: Color? = nil) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 20))
                .frame(width: 24)
            
            Text(text)
                .font(.system(size: 16))
            
            if let additionalText = additionalText {
                Text(additionalText)
                    .foregroundColor(additionalTextColor ?? color)
                    .font(.system(size: 16))
            }
            
            Spacer()
        }
    }
    
    private func formatCallDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return "\(minutes)m \(seconds)s"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Drag Indicator (only show in first level)
            if scrollLevel < 2 {
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 40, height: 5)
                    .padding(.vertical, 8)
            }
            
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
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 35) {
                            partnerDetailsSection
                                .transition(.move(edge: .top))
                            
                            phoneAndCallsRow
                                .transition(.opacity)
                            
                            locationHistorySection
                                .transition(.move(edge: .bottom))
                            
                            // Add extra padding at the bottom
                            Color.clear.frame(height: 100)
                        }
                        .padding(.vertical)
                        .frame(minHeight: geometry.size.height)
                    }
                }
                .background(Color.white)
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
                .clipShape(RoundedRectangle(cornerRadius: 15))
            }
        }
        .background(Color.white)
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

// Add InitialLoadingScreen
struct InitialLoadingScreen: View {
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 25) {
                // Placeholder for main artwork
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.orange.opacity(0.1))
                    .frame(width: 250, height: 250)
                    .overlay(
                        VStack {
                            Text("Main Artwork\nPlaceholder")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.orange)
                            Text("VICKY ART GO HERE")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.top, 5)
                        }
                    )
                
                Text("Connecting Hearts")
                    .font(.title.bold())
                    .foregroundColor(.orange)
                
                VStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.orange)
                    
                    Text("Loading your connection...")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

// Add CallHistoryView
struct CallHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    let partnerName: String
    @State private var selectedDate: Date
    @State private var weekDates: [Date] = []
    
    init(partnerName: String) {
        self.partnerName = partnerName
        // Initialize selectedDate with the current date
        _selectedDate = State(initialValue: Date())
    }
    
    // Sample call history data structure
    private var callHistoryByDate: [Date: [CallRecord]] {
        var history: [Date: [CallRecord]] = [:]
        
        // Create sample data for the past week
        for date in weekDates {
            let dayRecords = CallRecord.sampleRecords.filter { record in
                Calendar.current.isDate(record.timestamp, inSameDayAs: date)
            }
            if !dayRecords.isEmpty {
                history[date] = dayRecords
            }
        }
        
        return history
    }
    
    private func updateWeekDates() {
        let calendar = Calendar.current
        let today = Date()
        weekDates = (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: -dayOffset, to: today)
        }.reversed()
        
        // Ensure selectedDate is set to today when weekDates are updated
        selectedDate = today
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    private func formatDayNumber(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    // Add formatCallDuration function
    private func formatCallDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return "\(minutes)m \(seconds)s"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("\(partnerName)'s Call History")
                    .font(.title2.bold())
                    .foregroundColor(.orange)
                    .padding(.top)
                
                // Week Calendar
                HStack(spacing: 8) {
                    ForEach(weekDates, id: \.self) { date in
                        VStack(spacing: 8) {
                            Text(formatDate(date))
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Button(action: {
                                withAnimation {
                                    selectedDate = date
                                }
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Calendar.current.isDate(date, inSameDayAs: selectedDate) ? Color.orange : Color.clear)
                                        .frame(width: 36, height: 36)
                                    
                                    Text(formatDayNumber(date))
                                        .foregroundColor(Calendar.current.isDate(date, inSameDayAs: selectedDate) ? .white : .primary)
                                }
                            }
                            
                            // Call indicator
                            Circle()
                                .fill(callHistoryByDate[date] != nil ? Color.orange : Color.clear)
                                .frame(width: 4, height: 4)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white)
                        .shadow(color: Color.gray.opacity(0.2), radius: 5)
                )
                .padding(.horizontal)
                
                // Call List for Selected Date
                ScrollView {
                    VStack(spacing: 15) {
                        if let calls = callHistoryByDate[selectedDate] {
                            ForEach(calls) { record in
                                HStack {
                                    Image(systemName: "phone.fill")
                                        .foregroundColor(.green)
                                        .font(.system(size: 18))
                                        .frame(width: 24)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(record.contactName ?? record.phoneNumber)
                                            .font(.system(size: 16, weight: .medium))
                                        
                                        HStack {
                                            Text(formatCallDuration(record.duration))
                                                .font(.caption)
                                                .foregroundColor(.green)
                                            
                                            Text("•")
                                                .foregroundColor(.gray)
                                            
                                            Text(formatTime(record.timestamp))
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white)
                                        .shadow(color: Color.gray.opacity(0.1), radius: 3)
                                )
                            }
                        } else {
                            Text("No calls on this day")
                                .foregroundColor(.gray)
                                .padding()
                        }
                    }
                    .padding()
                }
            }
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
        .onAppear {
            updateWeekDates()
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

// Add PlacesHistoryView
struct PlacesHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    let partnerName: String
    @State private var selectedDate = Date()
    @State private var weekDates: [Date] = []
    let locationHistory: [LocationHistoryAnnotation]
    
    private var placesByDate: [Date: [LocationHistoryAnnotation]] {
        var places: [Date: [LocationHistoryAnnotation]] = [:]
        let calendar = Calendar.current
        
        for date in weekDates {
            let dayPlaces = locationHistory.filter { location in
                !location.isCurrentLocation && 
                calendar.isDate(location.timestamp, inSameDayAs: date) &&
                location.stayDuration >= 900 // 15 minutes
            }
            if !dayPlaces.isEmpty {
                places[date] = dayPlaces
            }
        }
        
        return places
    }
    
    private func updateWeekDates() {
        let calendar = Calendar.current
        let today = Date()
        weekDates = (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: -dayOffset, to: today)
        }.reversed()
        selectedDate = today
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    private func formatDayNumber(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
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
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("\(partnerName)'s Places")
                    .font(.title2.bold())
                    .foregroundColor(.orange)
                    .padding(.top)
                
                // Week Calendar
                HStack(spacing: 8) {
                    ForEach(weekDates, id: \.self) { date in
                        VStack(spacing: 8) {
                            Text(formatDate(date))
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Button(action: {
                                withAnimation {
                                    selectedDate = date
                                }
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Calendar.current.isDate(date, inSameDayAs: selectedDate) ? Color.orange : Color.clear)
                                        .frame(width: 36, height: 36)
                                    
                                    Text(formatDayNumber(date))
                                        .foregroundColor(Calendar.current.isDate(date, inSameDayAs: selectedDate) ? .white : .primary)
                                }
                            }
                            
                            // Place indicator
                            Circle()
                                .fill(placesByDate[date] != nil ? Color.orange : Color.clear)
                                .frame(width: 4, height: 4)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white)
                        .shadow(color: Color.gray.opacity(0.2), radius: 5)
                )
                .padding(.horizontal)
                
                // Places List for Selected Date
                ScrollView {
                    VStack(spacing: 15) {
                        if let places = placesByDate[selectedDate] {
                            ForEach(places) { place in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "mappin.circle.fill")
                                            .foregroundColor(.orange)
                                            .font(.system(size: 18))
                                        
                                        Text(place.address)
                                            .font(.system(size: 16, weight: .medium))
                                    }
                                    
                                    HStack {
                                        Text("Stayed for \(formatStayDuration(place.stayDuration))")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        
                                        Spacer()
                                        
                                        Text(formatTimeAgo(from: place.timestamp))
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white)
                                        .shadow(color: Color.gray.opacity(0.1), radius: 3)
                                )
                            }
                        } else {
                            Text("No places visited on this day")
                                .foregroundColor(.gray)
                                .padding()
                        }
                    }
                    .padding()
                }
            }
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
        .onAppear {
            updateWeekDates()
        }
    }
}

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    @EnvironmentObject private var userManager: UserManager
    let currentUser: User?
    
    @State private var zoomLevel: Double = 1.5
    @State private var isBottomSheetExpanded = false
    @State private var isInitialLoading = true // Initial app loading state
    
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
            if isInitialLoading {
                InitialLoadingScreen()
            } else {
                // Existing map view content
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
        }
        .onAppear {
            // Handle initial app loading
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { // Longer time for initial loading
                withAnimation(.easeInOut(duration: 0.5)) {
                    isInitialLoading = false
                    // Start loading the map after initial loading is done
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        locationManager.requestLocationPermission()
                    }
                }
            }
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