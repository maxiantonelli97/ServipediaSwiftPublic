//
//  Utils.swift
//  servipedia
//
//

import UIKit
import MapKit
import SystemConfiguration
import Foundation

class Utils: NSObject {
    func callNumber(phoneNumber:String) {
      if let phoneCallURL = URL(string: "tel://\(phoneNumber)") {
        let application:UIApplication = UIApplication.shared
        if (application.canOpenURL(phoneCallURL)) {
            application.open(phoneCallURL, options: [:], completionHandler: nil)
        }
      }
    }
    func openInstagram(insta:String) {
        let application:UIApplication = UIApplication.shared
        if let instaWeb = URL (string: insta){
          application.open(instaWeb, options: [:], completionHandler: nil)
        }
    }
    
    func sendWsp(phone: String) {
        let appURL = URL(string: "https://api.whatsapp.com/send?phone=\(phone)")!
        if UIApplication.shared.canOpenURL(appURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
            }
            else {
                UIApplication.shared.openURL(appURL)
            }
        }
    }
    
    func openMap(map: String) {
        if let mapURL = URL(string: "\(map)") {
          let application:UIApplication = UIApplication.shared
          if (application.canOpenURL(mapURL)) {
              application.open(mapURL, options: [:], completionHandler: nil)
          }
        }
    }
    
    func openMapLatLong(latitud: Double, longitud: Double, name: String) {
        let point = MKMapItem(
            placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: latitud, longitude: longitud))
        )
        
        point.openInMaps()
    }
}

public enum ReachabilityError: Error {
    case FailedToCreateWithAddress(sockaddr_in)
    case FailedToCreateWithHostname(String)
    case UnableToSetCallback
    case UnableToSetDispatchQueue
}

@available(*, unavailable, renamed: "Notification.Name.reachabilityChanged")
public let ReachabilityChangedNotification = NSNotification.Name("ReachabilityChangedNotification")

extension Notification.Name {
    public static let reachabilityChanged = Notification.Name("reachabilityChanged")
}

func callback(reachability: SCNetworkReachability, flags: SCNetworkReachabilityFlags, info: UnsafeMutableRawPointer?) {
    guard let info = info else { return }
    
    let reachability = Unmanaged<Reachability>.fromOpaque(info).takeUnretainedValue()
    reachability.reachabilityChanged()
}

public class Reachability {
    
    public typealias NetworkReachable = (Reachability) -> Void
    public typealias NetworkUnreachable = (Reachability) -> Void
    
    @available(*, unavailable, renamed: "Connection")
    public enum NetworkStatus: CustomStringConvertible {
        case notReachable, reachableViaWiFi, reachableViaWWAN
        public var description: String {
            switch self {
            case .reachableViaWWAN: return "Cellular"
            case .reachableViaWiFi: return "WiFi"
            case .notReachable: return "No Connection"
            }
        }
    }
    
    public enum Connection: CustomStringConvertible {
        case none, wifi, cellular
        public var description: String {
            switch self {
            case .cellular: return "Cellular"
            case .wifi: return "WiFi"
            case .none: return "No Connection"
            }
        }
    }
    
    public var whenReachable: NetworkReachable?
    public var whenUnreachable: NetworkUnreachable?
    
    @available(*, deprecated, renamed: "allowsCellularConnection")
    public let reachableOnWWAN: Bool = true
    
    /// Set to `false` to force Reachability.connection to .none when on cellular connection (default value `true`)
    public var allowsCellularConnection: Bool
    
    // The notification center on which "reachability changed" events are being posted
    public var notificationCenter: NotificationCenter = NotificationCenter.default
    
    @available(*, deprecated, renamed: "connection.description")
    public var currentReachabilityString: String {
        return "\(connection)"
    }
    
    @available(*, unavailable, renamed: "connection")
    public var currentReachabilityStatus: Connection {
        return connection
    }
    
    public var connection: Connection {
        guard isReachableFlagSet else { return .none }
        
        // If we're reachable, but not on an iOS device (i.e. simulator), we must be on WiFi
        guard isRunningOnDevice else { return .wifi }
        
        var connection = Connection.none
        
        if !isConnectionRequiredFlagSet {
            connection = .wifi
        }
        
        if isConnectionOnTrafficOrDemandFlagSet {
            if !isInterventionRequiredFlagSet {
                connection = .wifi
            }
        }
        
        if isOnWWANFlagSet {
            if !allowsCellularConnection {
                connection = .none
            } else {
                connection = .cellular
            }
        }
        
        return connection
    }
    
    fileprivate var previousFlags: SCNetworkReachabilityFlags?
    
    fileprivate var isRunningOnDevice: Bool = {
        #if targetEnvironment(simulator)
        return false
        #else
        return true
        #endif
    }()
    
    fileprivate var notifierRunning = false
    fileprivate let reachabilityRef: SCNetworkReachability
    
    fileprivate let reachabilitySerialQueue = DispatchQueue(label: "uk.co.ashleymills.reachability")
    
    fileprivate var usingHostname = false
    
    required public init(reachabilityRef: SCNetworkReachability, usingHostname: Bool = false) {
        allowsCellularConnection = true
        self.reachabilityRef = reachabilityRef
        self.usingHostname = usingHostname
    }
    
    public convenience init?(hostname: String) {
        guard let ref = SCNetworkReachabilityCreateWithName(nil, hostname) else { return nil }
        self.init(reachabilityRef: ref, usingHostname: true)
    }
    
    public convenience init?() {
        var zeroAddress = sockaddr()
        zeroAddress.sa_len = UInt8(MemoryLayout<sockaddr>.size)
        zeroAddress.sa_family = sa_family_t(AF_INET)
        
        guard let ref = SCNetworkReachabilityCreateWithAddress(nil, &zeroAddress) else { return nil }
        
        self.init(reachabilityRef: ref)
    }
    
    deinit {
        stopNotifier()
    }
    
    static func hayInternet(completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            completion(Reachability()?.connection != Reachability.Connection.none)
        }
    }
    
    static func hayInternet() -> Bool {
        return Reachability()?.connection != Reachability.Connection.none
    }
}

public extension Reachability {
    
    // MARK: - *** Notifier methods ***
    func startNotifier() throws {
        guard !notifierRunning else { return }
        
        var context = SCNetworkReachabilityContext(version: 0,
                                                   info: nil,
                                                   retain: nil,
                                                   release: nil,
                                                   copyDescription: nil)
        context.info = UnsafeMutableRawPointer(Unmanaged<Reachability>.passUnretained(self).toOpaque())
        if !SCNetworkReachabilitySetCallback(reachabilityRef, callback, &context) {
            stopNotifier()
            throw ReachabilityError.UnableToSetCallback
        }
        
        if !SCNetworkReachabilitySetDispatchQueue(reachabilityRef, reachabilitySerialQueue) {
            stopNotifier()
            throw ReachabilityError.UnableToSetDispatchQueue
        }
        
        // Perform an initial check
        reachabilitySerialQueue.async {
            self.reachabilityChanged()
        }
        
        notifierRunning = true
    }
    
    func stopNotifier() {
        defer { notifierRunning = false }
        
        SCNetworkReachabilitySetCallback(reachabilityRef, nil, nil)
        SCNetworkReachabilitySetDispatchQueue(reachabilityRef, nil)
    }
    
    // MARK: - *** Connection test meth**
    @available(*, deprecated, message: "Please use `connection != .none`")
    var isReachable: Bool {
        guard isReachableFlagSet else { return false }
        
        if isConnectionRequiredAndTransientFlagSet {
            return false
        }
        
        if isRunningOnDevice {
            if isOnWWANFlagSet && !reachableOnWWAN {
                // We don't want to connect when on cellular connection
                return false
            }
        }
        
        return true
    }
    @available(*, deprecated, message: "Please use `connection == .cellular`")
    var isReachableViaWWAN: Bool {
        // Check we're not on the simulator, we're REACHABLE and check we're on WWAN
        return isRunningOnDevice && isReachableFlagSet && isOnWWANFlagSet
    }
    
    @available(*, deprecated, message: "Please use `connection == .wifi`")
    var isReachableViaWiFi: Bool {
        // Check we're reachable
        guard isReachableFlagSet else { return false }
        
        // If reachable we're reachable, but not on an iOS device (i.e. simulator), we must be on WiFi
        guard isRunningOnDevice else { return true }
        
        // Check we're NOT on WWAN
        return !isOnWWANFlagSet
    }
    
    var description: String {
        let W = isRunningOnDevice ? (isOnWWANFlagSet ? "W": "-"): "X"
        let R = isReachableFlagSet ? "R": "-"
        let c = isConnectionRequiredFlagSet ? "c": "-"
        let t = isTransientConnectionFlagSet ? "t": "-"
        let i = isInterventionRequiredFlagSet ? "i": "-"
        let C = isConnectionOnTrafficFlagSet ? "C": "-"
        let D = isConnectionOnDemandFlagSet ? "D": "-"
        let l = isLocalAddressFlagSet ? "l": "-"
        let d = isDirectFlagSet ? "d": "-"
        
        return "\(W)\(R) \(c)\(t)\(i)\(C)\(D)\(l)\(d)"
    }
}

fileprivate extension Reachability {
    func reachabilityChanged() {
        guard previousFlags != flags else { return }
        
        let block = connection != .none ? whenReachable: whenUnreachable
        
        DispatchQueue.main.async {
            if self.usingHostname {
                debugPrint("USING HOSTNAME ABOUT TO CALL BLOCK")
            }
            block?(self)
            self.notificationCenter.post(name: .reachabilityChanged, object: self)
        }
        
        previousFlags = flags
    }
    
    var isOnWWANFlagSet: Bool {
        #if os(iOS)
        return flags.contains(.isWWAN)
        #else
        return false
        #endif
    }
    var isReachableFlagSet: Bool {
        return flags.contains(.reachable)
    }
    var isConnectionRequiredFlagSet: Bool {
        return flags.contains(.connectionRequired)
    }
    var isInterventionRequiredFlagSet: Bool {
        return flags.contains(.interventionRequired)
    }
    var isConnectionOnTrafficFlagSet: Bool {
        return flags.contains(.connectionOnTraffic)
    }
    var isConnectionOnDemandFlagSet: Bool {
        return flags.contains(.connectionOnDemand)
    }
    var isConnectionOnTrafficOrDemandFlagSet: Bool {
        return !flags.intersection([.connectionOnTraffic, .connectionOnDemand]).isEmpty
    }
    var isTransientConnectionFlagSet: Bool {
        return flags.contains(.transientConnection)
    }
    var isLocalAddressFlagSet: Bool {
        return flags.contains(.isLocalAddress)
    }
    var isDirectFlagSet: Bool {
        return flags.contains(.isDirect)
    }
    var isConnectionRequiredAndTransientFlagSet: Bool {
        return flags.intersection([.connectionRequired, .transientConnection]) ==
                [.connectionRequired, .transientConnection]
    }
    
    var flags: SCNetworkReachabilityFlags {
        var flags = SCNetworkReachabilityFlags()
        if SCNetworkReachabilityGetFlags(reachabilityRef, &flags) {
            return flags
        } else {
            return SCNetworkReachabilityFlags()
        }
    }
}
