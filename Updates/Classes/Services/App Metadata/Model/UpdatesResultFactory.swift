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
    
    private let apiResult: ITunesSearchAPIResult
    private let dependencies: Dependencies
    
    init(apiResult: ITunesSearchAPIResult, dependencies: Dependencies) {
        self.apiResult = apiResult
        self.dependencies = dependencies
    }
    
    private func isUpdateAvailableForSystemVersion() -> Bool {
        let appStoreVersion = apiResult.version
        let bundleVersion = dependencies.appVersion
        let comparator = dependencies.comparator
        let minRequiredOSVersion = apiResult.minimumOsVersion
        let operatingSystemVersion = dependencies.operatingSystemVersion
        let isNewVersionAvailable = updateAvailable(appVersion: bundleVersion, apiVersion: appStoreVersion,
                                                    comparator: comparator)
        let isRequiredOSAvailable = systemVersionAvailable(currentOSVersion: operatingSystemVersion,
                                                           requiredVersionString: minRequiredOSVersion)
        return isNewVersionAvailable && isRequiredOSAvailable
    }
    
    func manufacture() -> UpdatesResult {
        let isUpdateAvailable = isUpdateAvailableForSystemVersion()
        let update = Update(newVersionString: apiResult.version, releaseNotes: apiResult.releaseNotes,
                            shouldNotify: isUpdateAvailable)
        return (isUpdateAvailable) ? .available(update) : .none
    }
    
    /// Determines whether the required version of iOS is available on the current device.
    /// - parameter currentOSVersion The current version of iOS as determined by `UIDevice.current.systemVersion`.
    private func systemVersionAvailable(currentOSVersion: String, requiredVersionString: String) -> Bool {
        let comparisonResult = Updates.compareVersions(lhs: requiredVersionString,
                                                       rhs: currentOSVersion, comparator: .patch)
        return comparisonResult != .orderedDescending
    }
    
    private func updateAvailable(appVersion: String, apiVersion: String, comparator: VersionComparator) -> Bool {
        return Updates.compareVersions(lhs: appVersion, rhs: apiVersion, comparator: comparator) == .orderedAscending
    }
    
}
