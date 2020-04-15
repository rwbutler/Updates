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
    
    private let bundleVersion: String
    private let configuration: ConfigurationResult
    private let operatingSystemVersion: String
    
    init(configuration: ConfigurationResult, bundleVersion: String, operatingSystemVersion: String) {
        self.bundleVersion = bundleVersion
        self.configuration = configuration
        self.operatingSystemVersion = operatingSystemVersion
    }
    
    func manufacture() -> UpdatesResult {
        guard let appStoreVersion = configuration.version else {
            return .none
        }
        let isUpdateAvailable = isUpdateAvailableForSystemVersion()
        let update = Update(
            newVersionString: appStoreVersion,
            releaseNotes: configuration.releaseNotes,
            shouldNotify: isUpdateAvailable
        )
        return (isUpdateAvailable) ? .available(update) : .none
    }
    
}

private extension UpdatesResultFactory {
    
    private func isUpdateAvailableForSystemVersion() -> Bool {
        guard let appStoreVersion = configuration.version,
            let minRequiredOSVersion = configuration.minOSRequired else {
                return false
        }
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
