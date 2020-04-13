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
    
    static func checkForUpdatesAutomatically(comparingVersions comparator: VersionComparator = Updates.comparingVersions,
                                             currentOSVersion: String, notifying: NotificationMode = Updates.notifying,
                                             completion: @escaping (UpdatesResult) -> Void) {
        DispatchQueue.global(qos: .background).async {
            guard let bundleIdentifier = Updates.bundleIdentifier, let countryCode = Updates.countryCode,
                let appVersion = versionString,
                let metadataService = Services.appMetadata(bundleIdentifier: bundleIdentifier,
                                                           countryCode: countryCode) else {
                    DispatchQueue.main.async {
                        completion(.none)
                    }
                    return
            }
            metadataService.fetchAppMetadata { result in
                switch result {
                case .success(let apiResult):
                    let factoryDependencies = UpdatesResultFactory.Dependencies(
                        appVersion: appVersion,
                        comparator: comparator,
                        notifying: notifying,
                        operatingSystemVersion: currentOSVersion
                    )
                    let factory = UpdatesResultFactory(apiResult: apiResult, dependencies: factoryDependencies)
                    completion(factory.manufacture())
                case .failure:
                    onMainQueue(completion)(.none)
                }
            }
        }
    }
    
    static func checkForUpdatesManually(appStoreId: String,
                                        comparingVersions comparator: VersionComparator = Updates.comparingVersions,
                                        currentOSVersion: String, newVersionString: String,
                                        notifying: NotificationMode = Updates.notifying,
                                        minimumOSVersion: String, releaseNotes: String?,
                                        completion: @escaping (UpdatesResult) -> Void) {
        DispatchQueue.global(qos: .background).async {
            guard let appVersion = versionString else {
                onMainQueue(completion)(.none)
                return
            }
            let trackId = Int(appStoreId) ?? 0
            let apiResult = ITunesSearchAPIResult(minimumOsVersion: minimumOSVersion, releaseNotes: releaseNotes,
                                                  trackId: trackId, version: appVersion)
            let factoryDependencies = UpdatesResultFactory.Dependencies(
                appVersion: appVersion,
                comparator: comparator,
                notifying: notifying,
                operatingSystemVersion: currentOSVersion
            )
            let factory = UpdatesResultFactory(apiResult: apiResult, dependencies: factoryDependencies)
            completion(factory.manufacture())
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
    
    /// Pads out LHS array with zeroes
    static func padLHSWithZeroes(lhs: [String], rhs: [String]) -> [String] {
        var result = lhs
        while result.count < rhs.count {
            result.append("0")
        }
        return result
    }
    
    /// Records the current build so that we can determine
    static func addBuild(versionString: String, buildString: String, comparator: VersionComparator) {
        guard var versionInformation = cachedVersionInfo() else {
            postAppDidInstallNotification()
            var versionInfo = Versions()
            versionInfo.appendVersion(versionIdentifier: versionString, buildIdentifier: buildString)
            cacheVersionInfo(versionInfo: versionInfo)
            isFirstLaunchFollowingInstall = true
            return
        }
        let comparators: [VersionComparator] = [.major, .minor, .patch, .build]
        comparators.forEach { comparator in
            if !versionInformation.versionExists(versionIdentifier: versionString, comparator: comparator) {
                isFirstLaunchFollowingUpdate = true
                postAppVersionDidChangeNotification()
                versionInformation.appendVersion(versionIdentifier: versionString, buildIdentifier: buildString)
                cacheVersionInfo(versionInfo: versionInformation)
                return
            }
        }
        let buildExists = versionInformation.buildExists(versionIdentifier: versionString, buildIdentifier: buildString)
        if !buildExists, comparator.contains(.build) {
            isFirstLaunchFollowingUpdate = true
            postAppVersionDidChangeNotification()
            versionInformation.appendVersion(versionIdentifier: versionString, buildIdentifier: buildString)
            cacheVersionInfo(versionInfo: versionInformation)
        }
    }
    
    private static func postAppDidInstallNotification() {
        let appVersionDidChange = Notification(name: .appDidInstall)
        NotificationCenter.default.post(appVersionDidChange)
    }
    
    private static func postAppVersionDidChangeNotification() {
        let appVersionDidChange = Notification(name: .appVersionDidChange)
        NotificationCenter.default.post(appVersionDidChange)
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
