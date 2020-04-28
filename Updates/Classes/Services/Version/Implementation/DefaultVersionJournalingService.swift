//
//  DefaultVersionJournallingService.swift
//  Updates
//
//  Created by Ross Butler on 15/04/2020.
//

import Foundation

struct DefaultVersionJournalingService: VersionJournalingService {
    
    private let userDefaultsKey = "com.rwbutler.updates"
    
    /// Records the current build so that we can determine
    func registerBuild(versionString: String, buildString: String, comparator: VersionComparator) ->
        VersionJournalingServiceResult {
        guard var versionInformation = cachedVersionInfo() else {
            postAppDidInstallNotification()
            var versionInfo = Versions()
            versionInfo.appendVersion(versionIdentifier: versionString, buildIdentifier: buildString)
            cacheVersionInfo(versionInfo: versionInfo)

            return VersionJournalingServiceResult(
                isFirstLaunchFollowingInstall: true,
                isFirstLaunchFollowingUpdate: false
            )
        }
        var isFirstLaunchFollowingUpdate: Bool = false
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
        return VersionJournalingServiceResult(
            isFirstLaunchFollowingInstall: false,
            isFirstLaunchFollowingUpdate: isFirstLaunchFollowingUpdate
        )
    }
    
}

// MARK: - Caching

private extension DefaultVersionJournalingService {
    
    private func cachedVersionInfo() -> Versions? {
        let decoder = JSONDecoder()
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
            let versionInfo = try? decoder.decode(Versions.self, from: data) else {
                return nil
        }
        return versionInfo
    }
    
    private func cacheVersionInfo(versionInfo: Versions) {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(versionInfo) else { return }
        UserDefaults.standard.set(data, forKey: userDefaultsKey)
    }
    
}

// MARK: - Notifications

private extension DefaultVersionJournalingService {
    
    private func postAppDidInstallNotification() {
        let appVersionDidChange = Notification(name: .appDidInstall)
        NotificationCenter.default.post(appVersionDidChange)
    }
    
    private func postAppVersionDidChangeNotification() {
        let appVersionDidChange = Notification(name: .appVersionDidChange)
        NotificationCenter.default.post(appVersionDidChange)
    }
    
}
