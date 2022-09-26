//
//  DefaultVersionJournallingService.swift
//  Updates
//
//  Created by Ross Butler on 15/04/2020.
//

import Foundation

struct DefaultVersionJournalingService: VersionJournalingService {

    private let notificationCenter: NotificationCenter
    private let notificationsUserDefaultsKey = "com.rwbutler.updates.notifications"
    private let userDefaults: UserDefaults
    private let userDefaultsKey = "com.rwbutler.updates"

    init(notificationCenter: NotificationCenter = .default, userDefaults: UserDefaults = .standard) {
        self.notificationCenter = notificationCenter
        self.userDefaults = userDefaults
    }

    /// Record the fact that we have notified the user.
    func incrementNotificationCount(for version: String) {
        let notificationsUserDefaultsKey = "\(self.notificationsUserDefaultsKey).\(version)"
        let notificationCount = self.notificationCount(for: version) + 1
        userDefaults.setValue(notificationCount, forKey: notificationsUserDefaultsKey)
    }

    /// Returns the number of times we have notified the user about this version.
    func notificationCount(for version: String) -> Int {
        let notificationsUserDefaultsKey = "\(self.notificationsUserDefaultsKey).\(version)"
        return userDefaults.integer(forKey: notificationsUserDefaultsKey)
    }

    /// Records the current build so that we can determine
    func registerBuild(versionString: String, buildString: String?, comparator: VersionComparator) ->
        AppUpdatedResult {
        let buildString = buildString ?? "0"
        guard var versionInformation = cachedVersionInfo() else {
            postAppDidInstallNotification()
            var versionInfo = Versions()
            versionInfo.appendVersion(versionIdentifier: versionString, buildIdentifier: buildString)
            cacheVersionInfo(versionInfo: versionInfo)
            return AppUpdatedResult(
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
        return AppUpdatedResult(
            isFirstLaunchFollowingInstall: false,
            isFirstLaunchFollowingUpdate: isFirstLaunchFollowingUpdate
        )
    }

}

// MARK: - Caching

private extension DefaultVersionJournalingService {

    private func cachedVersionInfo() -> Versions? {
        let decoder = JSONDecoder()
        guard let data = userDefaults.data(forKey: userDefaultsKey),
            let versionInfo = try? decoder.decode(Versions.self, from: data) else {
                return nil
        }
        return versionInfo
    }

    private func cacheVersionInfo(versionInfo: Versions) {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(versionInfo) else { return }
        userDefaults.set(data, forKey: userDefaultsKey)
    }

}

// MARK: - Notifications

private extension DefaultVersionJournalingService {

    private func postAppDidInstallNotification() {
        let appVersionDidChange = Notification(name: .appDidInstall)
        notificationCenter.post(appVersionDidChange)
    }

    private func postAppVersionDidChangeNotification() {
        let appVersionDidChange = Notification(name: .appVersionDidChange)
        notificationCenter.post(appVersionDidChange)
    }

}
