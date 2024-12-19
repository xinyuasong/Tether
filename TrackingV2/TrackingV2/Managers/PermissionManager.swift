import CoreLocation
import CoreMotion
import UserNotifications
import HealthKit
import CoreBluetooth
import NearbyInteraction
import WeatherKit

class PermissionManager: NSObject, ObservableObject {
    @Published var locationAuthorized = false
    @Published var motionAuthorized = false
    @Published var notificationsAuthorized = false
    @Published var healthKitAuthorized = false
    @Published var bluetoothAuthorized = false
    @Published var nearbyInteractionAuthorized = false
    
    private let motionManager = CMMotionActivityManager()
    private let healthStore = HKHealthStore()
    private var bluetoothManager: CBCentralManager?
    private var nearbyInteractionManager: NISession?
    
    override init() {
        super.init()
        bluetoothManager = CBCentralManager(delegate: self, queue: nil)
        if #available(iOS 16.0, *) {
            nearbyInteractionManager = NISession()
            nearbyInteractionManager?.delegate = self
        }
    }
    
    func requestAllPermissions() {
        requestLocationPermission()
        requestMotionPermission()
        requestNotificationPermission()
        requestHealthKitPermission()
        requestBluetoothPermission()
        requestNearbyInteractionPermission()
    }
    
    private func requestLocationPermission() {
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func requestMotionPermission() {
        if CMMotionActivityManager.isActivityAvailable() {
            motionManager.queryActivityStarting(from: Date(), to: Date(), to: .main) { _, error in
                if error == nil {
                    self.motionAuthorized = true
                }
            }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                self.notificationsAuthorized = granted
            }
        }
    }
    
    private func requestHealthKitPermission() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, _ in
            DispatchQueue.main.async {
                self.healthKitAuthorized = success
            }
        }
    }
    
    private func requestBluetoothPermission() {
        bluetoothManager?.delegate = self
    }
    
    private func requestNearbyInteractionPermission() {
        if #available(iOS 16.0, *) {
            nearbyInteractionManager?.delegate = self
        }
    }
}

extension PermissionManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        DispatchQueue.main.async {
            switch central.state {
            case .poweredOn:
                self.bluetoothAuthorized = true
            case .unauthorized:
                self.bluetoothAuthorized = false
            case .poweredOff:
                self.bluetoothAuthorized = false
            default:
                break
            }
        }
    }
}

@available(iOS 16.0, *)
extension PermissionManager: NISessionDelegate {
    func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
        // Handle nearby objects updates
    }
    
    func session(_ session: NISession, didRemove nearbyObjects: [NINearbyObject], reason: NINearbyObject.RemovalReason) {
        // Handle nearby objects removal
    }
    
    func sessionWasSuspended(_ session: NISession) {
        nearbyInteractionAuthorized = false
    }
    
    func sessionSuspensionEnded(_ session: NISession) {
        nearbyInteractionAuthorized = true
    }
    
    func session(_ session: NISession, didInvalidateWith error: Error) {
        nearbyInteractionAuthorized = false
    }
} 
