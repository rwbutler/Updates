//
//  Updates.swift
//  Updates
//
//  Created by Ross Butler on 12/27/18.
//

import Foundation

public class Updates {
    
    // MARK: Global State
    
    public static var configurationType: ConfigurationType = {
        for configurationType in ConfigurationType.allCases {
            if bundledConfigurationURL(configurationType) != nil {
                return configurationType
            }
        }
        return .json // default
    }()
    
    /// Defaults configuration URL to bundled configuration detecting the type of config when set
    public static var configurationURL: URL? = bundledConfigurationURL() {
        didSet { // detect configuration format by extension
            guard let lastPathComponent = configurationURL?.lastPathComponent.lowercased() else { return }
            for configurationType in ConfigurationType.allCases {
                if lastPathComponent.contains(configurationType.rawValue.lowercased()) {
                    Updates.configurationType = configurationType
                    return
                }
            }
        }
    }
    
    /// Parses iTunes Search API responses.
    private static let parsingService: ITunesSearchJSONParsingService = ITunesSearchJSONParsingService()
    
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
    
    public static func checkForUpdates(completion: @escaping (UpdatesResult) -> Void) {
        // Check for updates using settings in configuration JSON
        if let configurationURL = configurationURL {
            if let configurationData = try? Data(contentsOf: configurationURL) {
                let parsingResult = ConfigurationJSONParsingService().parse(configurationData)
                switch parsingResult {
                case .success(let configuration):
                    checkForUpdates(configuration.updatingMode, comparingVersions: configuration.comparator,
                                    notifying: configuration.notificationMode, completion: completion)
                case .failure:
                    // TODO: Couldn't obtain configuration settings - read settings from cache
                    checkForUpdates(Updates.updatingMode, comparingVersions: comparingVersions,
                                    notifying: notifying, completion: completion)
                }
            }
        } else {
            // Check for updates using programmatic settings
            checkForUpdates(updatingMode, comparingVersions: comparingVersions, notifying: notifying,
                            completion: completion)
        }
    }
    
    public static func checkForUpdates(_ mode: UpdatingMode = Updates.updatingMode,
                                       comparingVersions comparator: Versions = Updates.comparingVersions,
                                       notifying: NotificationMode = Updates.notifying,
                                       completion: @escaping (UpdatesResult) -> Void) {
        switch updatingMode {
        case .automatically:
            checkForUpdatesAutomatically(completion: completion)
        case .manually:
            guard let appStoreId = self.appStoreId, let minimumOSVersion = self.minimumOSVersion,
                let newVersionString = self.newVersionString else {
                    let diagnosticMessage = """
                        Missing required information to check for updates manually. Requires App Store identifier,
                        minimum required OS version and version string for the new app version.
                    """
                    print(diagnosticMessage)
                    checkForUpdatesAutomatically(completion: completion)
                    return
            }
            checkForUpdatesManually(appStoreId: appStoreId, comparingVersions: comparator,
                                    newVersionString: newVersionString, notifying: notifying,
                                    minimumOSVersion: minimumOSVersion, completion: completion)
        }
    }
    
    public static var comparingVersions: Versions = .patch
    
    public static var countryCode: String? = Locale.current.regionCode
    
    public static var newVersionString: String?
    
    public static var notifying: NotificationMode = .once
    
    public static var minimumOSVersion: String?
    
    public static let productName: String? = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
    
    public static var updatingMode: UpdatingMode = .automatically
    
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
    
    static func bundledConfigurationURL(_ configType: ConfigurationType = Updates.configurationType) -> URL? {
        return Bundle.main.url(forResource: configurationName, withExtension: configType.rawValue)
    }
    
    private static var cachedConfigurationURL: URL? {
        return try? FileManager.default
            .url(for: .cachesDirectory,
                 in: .userDomainMask,
                 appropriateFor: nil,
                 create: true)
            .appendingPathComponent("\(configurationName).\(configurationType.rawValue)")
    }
    
    static func cacheExists() -> Bool {
        guard let cachedConfigURL = cachedConfigurationURL else { return false }
        return FileManager.default.fileExists(atPath: cachedConfigURL.path)
    }
    
    static func checkForUpdatesAutomatically(comparingVersions comparator: Versions = .semantic,
                                             notifying: NotificationMode = .once,
                                             completion: @escaping (UpdatesResult) -> Void) {
        DispatchQueue.global(qos: .background).async {
            guard let bundleIdentifier = Updates.bundleIdentifier,
                let apiURL = iTunesSearchAPIURL(bundleIdentifier: bundleIdentifier),
                let apiData = try? Data(contentsOf: apiURL), let parsingResult = parseConfiguration(data: apiData),
                let appVersionString = versionString else {
                    completion(.none)
                    return
            }
            if appStoreId == nil {
                appStoreId = String(parsingResult.trackId)
            }
            let isUpdateAvailable = updateAvailable(appVersion: appVersionString, apiVersion: parsingResult.version,
                                                    comparator: comparator)
            let isRequiredOSAvailable = requiredOSVersionAvailable(requiredOSVersion: parsingResult.minimumOsVersion)
            let isUpdateAvailableForCurrentDevice = isUpdateAvailable && isRequiredOSAvailable
            let update = Update(newVersionString: appVersionString, releaseNotes: parsingResult.releaseNotes,
                                shouldNotify: isUpdateAvailableForCurrentDevice)
            let result: UpdatesResult = isUpdateAvailableForCurrentDevice ? .available(update) : .none
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    static func checkForUpdatesManually(appStoreId: String,
                                        comparingVersions comparator: Versions = .semantic,
                                        newVersionString: String,
                                        notifying: NotificationMode = .once,
                                        minimumOSVersion: String,
                                        completion: @escaping (UpdatesResult) -> Void) {
        DispatchQueue.global(qos: .background).async {
            guard let appVersionString = versionString else {
                completion(.none)
                return
            }
            self.appStoreId = appStoreId
            let isUpdateAvailable = updateAvailable(appVersion: appVersionString, apiVersion: newVersionString,
                                                    comparator: comparator)
            let isRequiredOSAvailable = requiredOSVersionAvailable(requiredOSVersion: minimumOSVersion)
            let isUpdateAvailableForCurrentDevice = isUpdateAvailable && isRequiredOSAvailable
            let update = Update(newVersionString: newVersionString, releaseNotes: nil,
                                shouldNotify: isUpdateAvailableForCurrentDevice)
            let result: UpdatesResult = isUpdateAvailableForCurrentDevice ? .available(update) : .none
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    static func clearCache() {
        guard let cachedConfigURL = cachedConfigurationURL else { return }
        try? FileManager.default.removeItem(at: cachedConfigURL)
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
    
    static let configurationName: String = "Updates"
    
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
        switch parsingService.parse(data) {
        case .success(let result):
            return result
        case .failure:
            return nil
        }
    }
    
    /// Determines whether the required iOS version is available on the current device.
    static func requiredOSVersionAvailable(requiredOSVersion: String) -> Bool {
        let currentOSVersion = UIDevice.current.systemVersion
        let comparisonResult = compareVersions(lhs: requiredOSVersion, rhs: currentOSVersion)
        return comparisonResult != .orderedDescending
    }
    
}
