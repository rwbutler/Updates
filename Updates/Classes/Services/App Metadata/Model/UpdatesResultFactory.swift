//
//  UpdatesResultFactory.swift
//  Updates
//
//  Created by Ross Butler on 10/04/2020.
//

import Foundation

struct UpdatesResultFactory: Factory {
    
    struct Dependencies {
        let appVersion: String
        let comparator: VersionComparator
        let notifying: NotificationMode
        let operatingSystemVersion: String
    }
    
    private let configuration: ConfigurationResult
    private let journalingService: VersionJournalingService
    private let operatingSystemVersion: String
    
    init(
        configuration: ConfigurationResult,
        journalingService: VersionJournalingService,
        operatingSystemVersion: String
    ) {
        self.configuration = configuration
        self.journalingService = journalingService
        self.operatingSystemVersion = operatingSystemVersion
    }
    
    func manufacture() -> UpdatesResult {
        guard let bundleVersion = configuration.bundleVersion else {
            return .none(
                AppUpdatedResult(isFirstLaunchFollowingInstall: false, isFirstLaunchFollowingUpdate: false)
            )
        }
        if let minRequiredAppVersion = configuration.minRequiredAppVersion {
            if let minVersionUpdateAvailable = minVersionRequirement(
                minAppVersion: minRequiredAppVersion,
                bundleVersion: bundleVersion,
                configuration: configuration,
                updateType: .hard
            ) {
                return minVersionUpdateAvailable
            }
        }
        if let minOptionalAppVersion = configuration.minOptionalAppVersion {
            if let minVersionUpdateAvailable = minVersionRequirement(
                minAppVersion: minOptionalAppVersion,
                bundleVersion: bundleVersion,
                configuration: configuration,
                updateType: .soft
            ) {
                return minVersionUpdateAvailable
            }
        }
        guard let appStoreVersion = configuration.latestVersion,
              let minRequiredOSVersion = configuration.minOSRequired else {
                  return .none(
                    AppUpdatedResult(isFirstLaunchFollowingInstall: false, isFirstLaunchFollowingUpdate: false)
                  )
              }
        
        let isAppUpdated = self.isAppUpdated(bundleVersion: bundleVersion, configuration: configuration)
        let isUpdateAvailable = isUpdateAvailableForSystemVersion(
            appStoreVersion: appStoreVersion,
            bundleVersion: bundleVersion,
            comparator: configuration.comparator,
            minRequiredOSVersion: minRequiredOSVersion
        )
        let appStoreURL = configuration.appStoreId.flatMap { appStoreId in
            Updates.appStoreURL(
                appStoreId: appStoreId,
                countryCode: Updates.countryCode,
                productName: Updates.productName
            )
        }
        let update = Update(
            appStoreId: configuration.appStoreId,
            appStoreURL: appStoreURL,
            isUpdated: isAppUpdated,
            newVersionString: appStoreVersion,
            releaseNotes: configuration.releaseNotes,
            shouldNotify: isUpdateAvailable,
            updateType: configuration.updateType
        )
        let shouldNotify = self.shouldNotify(for: appStoreVersion)
        let willNotify = (isUpdateAvailable && shouldNotify)
        || (configuration.notificationMode == .withoutAvailableUpdate)
        return willNotify ? .available(update) : .none(isAppUpdated)
    }
    
}

private extension UpdatesResultFactory {
    
    private func isUpdateAvailableForSystemVersion(
        appStoreVersion: String,
        bundleVersion: String,
        comparator: VersionComparator,
        minRequiredOSVersion: String
    ) -> Bool {
        let isNewVersionAvailable = updateAvailable(
            appVersion: bundleVersion,
            apiVersion: appStoreVersion,
            comparator: comparator
        )
        let isRequiredOSAvailable = systemVersionAvailable(
            currentOSVersion: operatingSystemVersion,
            requiredVersionString: minRequiredOSVersion
        )
        return isNewVersionAvailable && isRequiredOSAvailable
    }
    
    private func isAppUpdated(bundleVersion: String, configuration: ConfigurationResult) -> AppUpdatedResult {
        return journalingService.registerBuild(
            versionString: bundleVersion,
            buildString: configuration.buildString,
            comparator: configuration.comparator
        )
    }
    
    private func minVersionRequirement(
        minAppVersion: String,
        bundleVersion: String,
        configuration: ConfigurationResult,
        updateType: UpdateType
    ) -> UpdatesResult? {
        let isMinVersionUpdateAvailable = Updates.compareVersions(
            lhs: bundleVersion, // version of the currently installed app.
            rhs: minAppVersion, // specified min version requirement.
            comparator: .patch  // compare using all components of the semantic version number.
        ) == .orderedAscending
        guard isMinVersionUpdateAvailable else {
            return nil
        }
        let isAppUpdated = self.isAppUpdated(bundleVersion: bundleVersion, configuration: configuration)
        let appStoreURL = configuration.appStoreId.flatMap { appStoreId in
            Updates.appStoreURL(
                appStoreId: appStoreId,
                countryCode: Updates.countryCode,
                productName: Updates.productName
            )
        }
        let update = Update(
            appStoreId: configuration.appStoreId,
            appStoreURL: appStoreURL,
            isUpdated: isAppUpdated,
            newVersionString: minAppVersion,
            releaseNotes: configuration.releaseNotes,
            shouldNotify: true,
            updateType: updateType
        )
        return .available(update)
    }
    
    /// Check whether we've notified the user about this version already.
    private func shouldNotify(for version: String) -> Bool {
        let notificationCount = journalingService.notificationCount(for: version)
        let notificationMode = configuration.notificationMode
        if notificationCount < notificationMode.notificationCount {
            journalingService.incrementNotificationCount(for: version)
            return true
        }
        return false
    }
    
    /// Determines whether the required version of iOS is available on the current device.
    /// - parameter currentOSVersion The current version of iOS as determined by `UIDevice.current.systemVersion`.
    private func systemVersionAvailable(currentOSVersion: String, requiredVersionString: String) -> Bool {
        let comparisonResult = Updates.compareVersions(
            lhs: requiredVersionString,
            rhs: currentOSVersion,
            comparator: .patch
        )
        return comparisonResult != .orderedDescending
    }
    
    private func updateAvailable(appVersion: String, apiVersion: String, comparator: VersionComparator) -> Bool {
        return Updates.compareVersions(lhs: appVersion, rhs: apiVersion, comparator: comparator) == .orderedAscending
    }
    
}
