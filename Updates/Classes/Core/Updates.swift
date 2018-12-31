//
//  Updates.swift
//  Updates
//
//  Created by Ross Butler on 12/27/18.
//

import Foundation

public class Updates {
    
    /// Parses iTunes Search API responses.
    private static let parsingService: ParsingService = JSONParsingService()
    
    public static var appStoreId: String? {
        didSet {
            guard appStoreURL == nil, let appStoreId = appStoreId, let productName = productName else {
                return
            }
            appStoreURL = appStoreURL(appStoreId: appStoreId, productName: productName)
        }
    }
    
    public static var appStoreURL: URL?
    
    public static let buildString: String? =  Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String
    
    public static var bundleIdentifier: String? = Bundle.main.bundleIdentifier
    
    public static func checkForUpdates(_ mode: UpdatingMode = .automatically,
                                       comparingVersions comparator: Versions = .semantic,
                                       notifying: NotificationMode = .once, completion: @escaping (Bool) -> Void) {
        guard let bundleIdentifier = Updates.bundleIdentifier,
            let apiURL = iTunesSearchAPIURL(bundleIdentifier: bundleIdentifier),
            let apiData = try? Data(contentsOf: apiURL), let result = parseConfiguration(data: apiData),
            let appVersionString = versionString else {
                completion(false)
                return
        }
        if appStoreId == nil {
            appStoreId = String(result.trackId)
        }
        let isUpdateAvailable = updateAvailable(appVersion: appVersionString, apiVersion: result.version,
                                                comparator: comparator)
        let isRequiredOSAvailable = requiredOSVersionAvailable(requiredOSVersion: result.minimumOsVersion)
        let isUpdateAvailableForCurrentDevice = isUpdateAvailable && isRequiredOSAvailable
        completion(isUpdateAvailableForCurrentDevice)
    }
    
    public static var countryCode: String? = Locale.current.regionCode
    
    public static let productName: String? = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
    
    public static let versionString: String? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
}

private extension Updates {
    
    /// Returns the URL to open the app with the specified identifier in the App Store.
    /// - Parameters:
    ///     - appStoreId: The app store identifier specified as a String.
    /// - Returns: The URL required to launch the App Store page for the specified app,
    /// provided a valid identifier is provided.
    static func appStoreURL(appStoreId: String, countryCode: String? = nil, productName: String) -> URL? {
        guard let countryCode = countryCode ?? Updates.countryCode else {
            return nil
        }
        let lowercasedCountryCode = countryCode.lowercased()
        let lowercasedProductName = productName.lowercased()
        let urlString = "https://itunes.apple.com/\(lowercasedCountryCode)/app/\(lowercasedProductName)/id\(appStoreId)"
        return URL(string: urlString)
    }
    
    /**
     Compares two semantic version numbers.
     - parameter lhs: First semantic version number.
     - parameter rhs: Second semantic version number.
     - returns: .orderedSame if versions are equal, .orderedAscending if lhs is earlier than rhs
     and orderedDescending if rhs is earlier than lhs.
     */
    static func compareVersions(lhs: String, rhs: String) -> ComparisonResult {
        var result = ComparisonResult.orderedSame
        var versionComponents = lhs.components(separatedBy: ".")
        var versionToCompareComponents = rhs.components(separatedBy: ".")
        
        // Pad out the array to make equal in length
        while versionComponents.count < versionToCompareComponents.count {
            versionComponents.append("0")
        }
        
        while versionComponents.count > versionToCompareComponents.count {
            versionToCompareComponents.append("0")
        }
        
        for i in 0..<versionComponents.count {
            if let versionComponent = Int(versionComponents[i]),
                let versionToCompareComponent = Int(versionToCompareComponents[i]) {
                if versionComponent < versionToCompareComponent {
                    result = ComparisonResult.orderedAscending
                    break
                }
                if versionComponent > versionToCompareComponent {
                    result = ComparisonResult.orderedDescending
                    break
                }
            }
        }
        return result
    }
    
    static func updateAvailable(appVersion: String, apiVersion: String, comparator: Versions) -> Bool {
        let semanticVersioningComponents: [Versions] = [.major, .minor, .patch]
        var versionComponents = appVersion.components(separatedBy: ".")
        var versionToCompareComponents = apiVersion.components(separatedBy: ".")
        
        while versionComponents.count < versionToCompareComponents.count {
            versionComponents.append("0")
        }
        
        while versionComponents.count > versionToCompareComponents.count {
            versionToCompareComponents.append("0")
        }
        
        for i in 0..<versionComponents.count {
            if let versionComponent = Int(versionComponents[i]),
                let versionToCompareComponent = Int(versionToCompareComponents[i]),
                i < semanticVersioningComponents.count {
                let semanticVersioningComponent = semanticVersioningComponents[i]
                if versionComponent < versionToCompareComponent, comparator.contains(semanticVersioningComponent) {
                    return true
                }
            }
        }
        return false
    }
    
    static func iTunesSearchAPIURL(bundleIdentifier: String, countryCode: String? = nil) -> URL? {
        guard let countryCode = countryCode ?? Updates.countryCode else {
            return nil
        }
        let lowercasedCountryCode = countryCode.lowercased()
        let urlString = "http://itunes.apple.com/lookup?bundleId=\(bundleIdentifier)&country=\(lowercasedCountryCode)"
        return URL(string: urlString)
    }
    
    /// Parses data returned by the iTunes Search API.
    private static func parseConfiguration(data: Data) -> ParsingServiceResult? {
        return parsingService.parse(data)
    }
    
    /// Determines whether the required iOS version is available on the current device.
    static func requiredOSVersionAvailable(requiredOSVersion: String) -> Bool {
        let currentOSVersion = UIDevice.current.systemVersion
        let comparisonResult = compareVersions(lhs: requiredOSVersion, rhs: currentOSVersion)
        return comparisonResult != .orderedDescending
    }
    
}
