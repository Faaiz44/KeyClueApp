import Foundation
import Firebase
import FirebaseRemoteConfig

enum ValueKey: String {
    case appPrimaryColor
}
class RCValues {
    
    static let sharedInstance = RCValues()
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.white
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    private init() {
        loadDefaultValues()
    }
    
    func loadDefaultValues() {
        let appDefaults: [String: NSObject] = [
            ValueKey.appPrimaryColor.rawValue : "#FFFFFF" as NSObject
        ]
        RemoteConfig.remoteConfig().setDefaults(appDefaults)
    }
    
    func fetchCloudValues() {
        let fetchDuration: TimeInterval = 0
        activateDebugMode()
        RemoteConfig.remoteConfig().fetch(withExpirationDuration: fetchDuration) {
            [weak self] (status, error) in
            
            guard error == nil else {
                print ("Uh-oh. Got an error fetching remote values \(error)")
                return
            }
            
            // 2
            RemoteConfig.remoteConfig().activateFetched()
            print ("Retrieved values from the cloud!")
        }
    }
    
    func color(forKey key: ValueKey) -> UIColor {
        let colorAsHexString = RemoteConfig.remoteConfig()[key.rawValue].stringValue
        let convertedColor = hexStringToUIColor(hex: colorAsHexString!)
        return convertedColor
    }
    
    func activateDebugMode() {
        let debugSettings = RemoteConfigSettings(developerModeEnabled: true)
        RemoteConfig.remoteConfig().configSettings = debugSettings!
    }
}
