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
    
    /// Returns the URL to open the app with the specified identifier in the App Store.
    /// - Parameters:
    ///     - appStoreId: The app store identifier specified as a String.
    /// - Returns: The URL required to launch the App Store page for the specified app,
    /// provided a valid identifier is provided.
    static func appStoreURL(for appStoreId: String) -> URL? {
        Updates.appStoreId = appStoreId
        return appStoreURL
    }
    
    public static let buildString: String? = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String
    
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
                                       comparingVersions comparator: VersionComparator = Updates.comparingVersions,
                                       notifying: NotificationMode = Updates.notifying,
                                       releaseNotes: String? = nil,
                                       completion: @escaping (UpdatesResult) -> Void) {
        
        if let versionString = versionString, let buildString = buildString {
            addBuild(versionString: versionString, buildString: buildString, comparator: .build)
        }
        
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
        case .never:
            completion(.none)
        }
    }
    
    public static var comparingVersions: VersionComparator = .patch
    
    public static var countryCode: String? = Locale.current.regionCode
    
    public internal(set) static var isFirstLaunchFollowingInstall: Bool = false
    
    public internal(set) static var isFirstLaunchFollowingUpdate: Bool = false
    
    public static var newVersionString: String?
    
    public static var notifying: NotificationMode = .once
    
    public static var minimumOSVersion: String?
    
    public static let productName: String? = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
    
    public static var releaseNotes: String?
    
    /// Determines whether the required version of iOS is available on the current device.
    @objc public static func systemVersionAvailable(_ systemVersionString: String) -> Bool {
        let currentOSVersion = UIDevice.current.systemVersion
        let comparisonResult = compareVersions(lhs: systemVersionString, rhs: currentOSVersion, comparator: .patch)
        return comparisonResult != .orderedDescending
    }
    
    public static var updatingMode: UpdatingMode = .automatically
    
    internal static let userDefaultsKey = "com.rwbutler.updates"
    
    public static let versionString: String? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
}
