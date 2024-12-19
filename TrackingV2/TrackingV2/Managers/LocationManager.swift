import CoreLocation
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    // Waterloo coordinates
    private let waterloo = CLLocationCoordinate2D(latitude: 43.4643, longitude: -80.5204)
    
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 43.4643, longitude: -80.5204),
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )
    
    @Published var userLocation: CLLocation?
    @Published var partnerLocation: CLLocation?
    
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationError: String?
    
    override init() {
        super.init()
        setupLocationManager()
        
        // Set initial location for testing in simulator
        #if targetEnvironment(simulator)
        self.userLocation = CLLocation(latitude: waterloo.latitude, longitude: waterloo.longitude)
        #endif
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // Update location every 10 meters
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.pausesLocationUpdatesAutomatically = false
        
        // Request background location updates
        if Bundle.main.object(forInfoDictionaryKey: "UIBackgroundModes") != nil {
            locationManager.startMonitoringSignificantLocationChanges()
        }
        
        #if targetEnvironment(simulator)
        // For simulator testing, don't actually start location updates
        self.userLocation = CLLocation(latitude: waterloo.latitude, longitude: waterloo.longitude)
        #else
        locationManager.startUpdatingLocation()
        #endif
    }
    
    func requestLocationPermission() {
        // Request "Always" authorization for background updates
        locationManager.requestAlwaysAuthorization()
        
        #if targetEnvironment(simulator)
        // Immediately set Waterloo location for simulator
        self.userLocation = CLLocation(latitude: waterloo.latitude, longitude: waterloo.longitude)
        #endif
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        #if targetEnvironment(simulator)
        // Keep the fixed Waterloo location for simulator
        userLocation = CLLocation(latitude: waterloo.latitude, longitude: waterloo.longitude)
        #else
        guard let location = locations.last else { return }
        userLocation = location
        
        // Handle background location updates
        if UIApplication.shared.applicationState == .background {
            // Here you would typically send the location to your backend
            print("Background location update: \(location.coordinate)")
        }
        #endif
        
        // Update region to show both user and partner
        updateRegion()
    }
    
    private func updateRegion() {
        guard let userLoc = userLocation else { return }
        
        if let partnerLocation = partnerLocation {
            let center = CLLocationCoordinate2D(
                latitude: (userLoc.coordinate.latitude + partnerLocation.coordinate.latitude) / 2,
                longitude: (userLoc.coordinate.longitude + partnerLocation.coordinate.longitude) / 2
            )
            
            let span = MKCoordinateSpan(
                latitudeDelta: abs(userLoc.coordinate.latitude - partnerLocation.coordinate.latitude) * 2,
                longitudeDelta: abs(userLoc.coordinate.longitude - partnerLocation.coordinate.longitude) * 2
            )
            
            region = MKCoordinateRegion(center: center, span: span)
        } else {
            region = MKCoordinateRegion(
                center: userLoc.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
            )
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        
        switch status {
        case .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.startMonitoringSignificantLocationChanges()
        case .denied:
            locationError = "Location access denied. Please enable it in Settings to use this app."
        case .restricted:
            locationError = "Location access restricted. Please check your device settings."
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                locationError = "Location access denied. Please enable it in Settings."
            case .locationUnknown:
                locationError = "Unable to determine location. Please try again."
            default:
                locationError = "Location error: \(error.localizedDescription)"
            }
        }
        print("Location manager failed with error: \(error.localizedDescription)")
    }
} 