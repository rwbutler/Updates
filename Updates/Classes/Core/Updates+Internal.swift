//
//  Updates+Internal.swift
//  Updates
//
//  Created by Ross Butler on 3/4/19.
//

import Foundation

extension Updates {
    
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
    
    static var cachedConfigurationURL: URL? {
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
    
    static func checkForUpdatesAutomatically(comparingVersions
        comparator: VersionComparator = Updates.comparingVersions,
                                             currentOSVersion: String,
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
            let isUpdateAvailable = isUpdateAvailableForSystemVersion(comparingVersions: comparator,
                                                                      currentAppVersion: appVersionString,
                                                                      currentOSVersion: currentOSVersion,
                                                                      minimumRequiredOS: parsingResult.minimumOsVersion,
                                                                      newAppVersion: parsingResult.version)
            let update = Update(newVersionString: parsingResult.version,
                                releaseNotes: parsingResult.releaseNotes,
                                shouldNotify: isUpdateAvailable)
            let result: UpdatesResult = isUpdateAvailable ? .available(update) : .none
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    static func isUpdateAvailableForSystemVersion(comparingVersions comparator: VersionComparator,
                                                  currentAppVersion: String, currentOSVersion: String,
                                                  minimumRequiredOS: String,
                                                  newAppVersion: String) -> Bool {
        let isNewVersionAvailable = updateAvailable(appVersion: currentAppVersion, apiVersion: newAppVersion,
                                                    comparator: comparator)
        let isRequiredOSAvailable = systemVersionAvailable(currentOSVersion: currentOSVersion,
                                                           requiredVersionString: minimumRequiredOS)
        return isNewVersionAvailable && isRequiredOSAvailable
    }
    
    static func checkForUpdatesManually(appStoreId: String,
                                        comparingVersions comparator: VersionComparator = Updates.comparingVersions,
                                        currentOSVersion: String, newVersionString: String,
                                        notifying: NotificationMode = Updates.notifying,
                                        minimumOSVersion: String, releaseNotes: String?,
                                        completion: @escaping (UpdatesResult) -> Void) {
        DispatchQueue.global(qos: .background).async {
            guard let appVersionString = versionString else {
                DispatchQueue.main.async {
                    completion(.none)
                }
                return
            }
            self.appStoreId = appStoreId
            let isUpdateAvailable = isUpdateAvailableForSystemVersion(comparingVersions: comparator,
                                                                      currentAppVersion: appVersionString,
                                                                      currentOSVersion: currentOSVersion,
                                                                      minimumRequiredOS: minimumOSVersion,
                                                                      newAppVersion: newVersionString)
            let update = Update(newVersionString: newVersionString, releaseNotes: releaseNotes,
                                shouldNotify: isUpdateAvailable)
            let result: UpdatesResult = isUpdateAvailable ? .available(update) : .none
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
    static func compareVersions(lhs: String, rhs: String, comparator: VersionComparator) -> ComparisonResult {
        let semanticVersioningComponents: [VersionComparator] = [.major, .minor, .patch, .build]
        var result = ComparisonResult.orderedSame
        var lhsComponents = lhs.components(separatedBy: ".")
        var rhsComponents = rhs.components(separatedBy: ".")
        
        // Pad out the array to make equal in length
        lhsComponents = padLHSWithZeroes(lhs: lhsComponents, rhs: rhsComponents)
        rhsComponents = padLHSWithZeroes(lhs: rhsComponents, rhs: lhsComponents)
        var counter = 0
        for (lhsComponent, rhsComponent) in zip(lhsComponents, rhsComponents) {
            let semanticComponent = semanticVersioningComponents[counter]
            guard semanticComponent.rawValue <= comparator.rawValue else { break }
            result = comparisonResult(lhs: lhsComponent, rhs: rhsComponent)
            if result != .orderedSame {
                break
            }
            counter += 1
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
    
    public static func updateAvailable(appVersion: String, apiVersion: String, comparator: VersionComparator) -> Bool {
        return compareVersions(lhs: appVersion, rhs: apiVersion, comparator: comparator) == .orderedAscending
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
    
    /// Records the current build so that we can determine
    static func addBuild(versionString: String, buildString: String, comparator: VersionComparator) {
        guard var versionInformation = cachedVersionInfo() else {
            var versionInfo = Versions()
            versionInfo.appendVersion(versionIdentifier: versionString, buildIdentifier: buildString)
            cacheVersionInfo(versionInfo: versionInfo)
            isFirstLaunchFollowingInstall = true
            return
        }
        guard versionInformation.versionExists(versionIdentifier: versionString, comparator: .patch) else {
            isFirstLaunchFollowingUpdate = true
            versionInformation.appendVersion(versionIdentifier: versionString, buildIdentifier: buildString)
            cacheVersionInfo(versionInfo: versionInformation)
            return
        }
        let buildExists = versionInformation.buildExists(versionIdentifier: versionString, buildIdentifier: buildString)
        if !buildExists, comparator.contains(.build) {
            isFirstLaunchFollowingUpdate = true
            versionInformation.appendVersion(versionIdentifier: versionString, buildIdentifier: buildString)
            cacheVersionInfo(versionInfo: versionInformation)
        }
    }
    
    private static func cachedVersionInfo() -> Versions? {
        let decoder = JSONDecoder()
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
            let versionInfo = try? decoder.decode(Versions.self, from: data) else {
                return nil
        }
        return versionInfo
    }
    
    private static func cacheVersionInfo(versionInfo: Versions) {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(versionInfo) else { return }
        UserDefaults.standard.set(data, forKey: userDefaultsKey)
    }
}
