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
        guard let appStoreVersion = configuration.latestVersion,
              let bundleVersion = configuration.bundleVersion,
              let minRequiredOSVersion = configuration.minOSRequired else {
            return .none
        }
        let isUpdateAvailable = isUpdateAvailableForSystemVersion(
            appStoreVersion: appStoreVersion,
            bundleVersion: bundleVersion,
            minRequiredOSVersion: minRequiredOSVersion
        )
        let shouldNotify = self.shouldNotify(for: appStoreVersion)
        let update = Update(
            appStoreId: configuration.appStoreId,
            newVersionString: appStoreVersion,
            releaseNotes: configuration.releaseNotes,
            shouldNotify: isUpdateAvailable
        )
        let willNotify = (isUpdateAvailable && shouldNotify)
            || (configuration.notificationMode == .withoutAvailableUpdate)
        return willNotify ? .available(update) : .none
    }
    
}

private extension UpdatesResultFactory {
    
    private func isUpdateAvailableForSystemVersion(
        appStoreVersion: String,
        bundleVersion: String,
        minRequiredOSVersion: String
    ) -> Bool {
        let comparator = configuration.comparator
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
