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
                    cacheConfiguration(configuration)
                    checkForUpdates(configuration.updatingMode, comparingVersions: configuration.comparator,
                                    notifying: configuration.notificationMode, releaseNotes: configuration.releaseNotes,
                                    completion: completion)
                case .failure:
                    // Attempt to use last cached configuration first
                    if let cachedConfigurationURL = cachedConfigurationURL,
                        let cachedData = try? Data(contentsOf: cachedConfigurationURL),
                        case let .success(configuration) = ConfigurationJSONParsingService().parse(cachedData) {
                        checkForUpdates(configuration.updatingMode, comparingVersions: configuration.comparator,
                                        notifying: configuration.notificationMode,
                                        releaseNotes: configuration.releaseNotes, completion: completion)
                    } else {
                        // Fallback to programmatic settings
                        checkForUpdates(Updates.updatingMode, comparingVersions: comparingVersions,
                                        notifying: notifying, releaseNotes: releaseNotes, completion: completion)
                    }
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
                                       releaseNotes: String? = nil,
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
                                    minimumOSVersion: minimumOSVersion, releaseNotes: releaseNotes,
                                    completion: completion)
        }
    }
    
    public static var comparingVersions: Versions = .patch
    
    public static var countryCode: String? = Locale.current.regionCode
    
    public static var newVersionString: String?
    
    public static var notifying: NotificationMode = .once
    
    public static var minimumOSVersion: String?
    
    public static let productName: String? = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
    
    public static var releaseNotes: String?
    
    /// Determines whether the required version of iOS is available on the current device.
    @objc public static func systemVersionAvailable(_ systemVersionString: String) -> Bool {
        let currentOSVersion = UIDevice.current.systemVersion
        let comparisonResult = compareVersions(lhs: systemVersionString, rhs: currentOSVersion)
        return comparisonResult != .orderedDescending
    }
    
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
    
    static func cacheConfiguration(_ result: ConfigurationResult) {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(result),
            let cachedConfigurationURL = cachedConfigurationURL else { return }
        try? data.write(to: cachedConfigurationURL)
    }
    
    static func cacheExists() -> Bool {
        guard let cachedConfigURL = cachedConfigurationURL else { return false }
        return FileManager.default.fileExists(atPath: cachedConfigURL.path)
    }
    
    static func checkForUpdatesAutomatically(comparingVersions comparator: Versions = Updates.comparingVersions,
                                             notifying: NotificationMode = Updates.notifying,
                                             completion: @escaping (UpdatesResult) -> Void) {
        DispatchQueue.global(qos: .background).async {
            guard let bundleIdentifier = Updates.bundleIdentifier,
                let apiURL = iTunesSearchAPIURL(bundleIdentifier: bundleIdentifier),
                let apiData = try? Data(contentsOf: apiURL), let parsingResult = parseConfiguration(data: apiData),
                let appVersionString = versionString else {
                    DispatchQueue.main.async {
                        completion(.none)
                    }
                    return
            }
            appStoreId = appStoreId ?? String(parsingResult.trackId)
            let isUpdateAvailable = isUpdateAvailableForCurrentOS(comparingVersions: comparator,
                                                                  currentAppVersion: appVersionString,
                                                                  minimumRequiredOS: parsingResult.minimumOsVersion,
                                                                  newAppVersion: parsingResult.version)
            DispatchQueue.main.async {
                if isUpdateAvailable {
                    let update = Update(newVersionString: parsingResult.version,
                                        releaseNotes: parsingResult.releaseNotes,
                                        shouldNotify: isUpdateAvailable)
                    completion(.available(update))
                } else {
                    completion(.none)
                }
            }
        }
    }
    
    static func isUpdateAvailableForCurrentOS(comparingVersions comparator: Versions, currentAppVersion: String,
                                              minimumRequiredOS: String, newAppVersion: String) -> Bool {
        let isNewVersionAvailable = updateAvailable(appVersion: currentAppVersion, apiVersion: newAppVersion,
                                                    comparator: comparator)
        let isRequiredOSAvailable = systemVersionAvailable(minimumRequiredOS)
        return isNewVersionAvailable && isRequiredOSAvailable
    }
    
    static func checkForUpdatesManually(appStoreId: String,
                                        comparingVersions comparator: Versions = Updates.comparingVersions,
                                        newVersionString: String,
                                        notifying: NotificationMode = Updates.notifying,
                                        minimumOSVersion: String,
                                        releaseNotes: String?,
                                        completion: @escaping (UpdatesResult) -> Void) {
        DispatchQueue.global(qos: .background).async {
            guard let appVersionString = versionString else {
                DispatchQueue.main.async {
                    completion(.none)
                }
                return
            }
            self.appStoreId = appStoreId
            let isUpdateAvailable = updateAvailable(appVersion: appVersionString, apiVersion: newVersionString,
                                                    comparator: comparator)
            let isRequiredOSAvailable = systemVersionAvailable(minimumOSVersion)
            let isUpdateAvailableForCurrentDevice = isUpdateAvailable && isRequiredOSAvailable
            let update = Update(newVersionString: newVersionString, releaseNotes: releaseNotes,
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
        var lhsComponents = lhs.components(separatedBy: ".")
        var rhsComponents = rhs.components(separatedBy: ".")
        
        // Pad out the array to make equal in length
        lhsComponents = padLHSWithZeroes(lhs: lhsComponents, rhs: rhsComponents)
        rhsComponents = padLHSWithZeroes(lhs: rhsComponents, rhs: lhsComponents)
        for (lhsComponent, rhsComponent) in zip(lhsComponents, rhsComponents) {
            result = comparisonResult(lhs: lhsComponent, rhs: rhsComponent)
            if result != .orderedSame {
                break
            }
        }
        return result
    }
    
    static func comparisonResult(lhs: Int, rhs: Int) -> ComparisonResult {
        var result = ComparisonResult.orderedSame
        if lhs < rhs {
            result = ComparisonResult.orderedAscending
        } else if lhs > rhs {
            result = ComparisonResult.orderedDescending
        }
        return result
    }
    
    static func comparisonResult(lhs: String, rhs: String) -> ComparisonResult {
        var result: ComparisonResult = .orderedSame
        if let lhsComponent = Int(lhs), let rhsComponent = Int(rhs) {
            result = comparisonResult(lhs: lhsComponent, rhs: rhsComponent)
        } else if lhs < rhs {
            result = .orderedAscending
        } else if lhs > rhs {
            result = .orderedDescending
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
                if versionComponent < versionToCompareComponent, semanticVersioningComponent <= comparator {
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
    
    /// Pads out LHS array with zeroes
    static func padLHSWithZeroes(lhs: [String], rhs: [String]) -> [String] {
        var result = lhs
        while result.count < rhs.count {
            result.append("0")
        }
        return result
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
    
    /// Parses iTunes Search API responses.
    private static let parsingService: ITunesSearchJSONParsingService = ITunesSearchJSONParsingService()
    
}
