//
//  ConfigurationResult.swift
//  Updates
//
//  Created by Ross Butler on 1/4/19.
//

import Foundation

struct ConfigurationResult: Codable {

    enum CodingKeys: String, CodingKey {
        case appStoreId = "app-store-id"
        case build
        case bundleVersion = "bundle-version"
        case comparing
        case minOSRequired = "min-os-required"
        case minOptionalAppVersion = "min-optional-app-version"
        case minRequiredAppVersion = "min-required-app-version"
        case notificationMode = "notify"
        case releaseNotes = "release-notes"
        case updateType = "update-type"
        case updatingMode = "check-for"
        case version
    }

    let appStoreId: String?
    let bundleVersion: String?
    let buildString: String?
    let comparator: VersionComparator
    let minOptionalAppVersion: String?
    let minOSRequired: String?
    let minRequiredAppVersion: String?
    let notificationMode: NotificationMode
    let releaseNotes: String?
    let updatingMode: UpdatingMode
    let latestVersion: String?
    let updateType: UpdateType

    init(
        appStoreId: String?,
        buildString: String?,
        bundleVersion: String?,
        comparator: VersionComparator,
        minOptionalAppVersion: String?,
        minRequiredAppVersion: String?,
        minRequiredOSVersion: String?,
        notifying: NotificationMode,
        releaseNotes: String?,
        updateType: UpdateType,
        updatingMode: UpdatingMode,
        latestVersion: String?
    ) {
        self.appStoreId = appStoreId
        self.buildString = buildString
        self.bundleVersion = bundleVersion
        self.comparator = comparator
        self.minOSRequired = minRequiredOSVersion
        self.minOptionalAppVersion = minOptionalAppVersion
        self.minRequiredAppVersion = minRequiredAppVersion
        self.notificationMode = notifying
        self.releaseNotes = releaseNotes
        self.updateType = updateType
        self.updatingMode = updatingMode
        self.latestVersion = latestVersion
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.appStoreId = try? container.decode(String.self, forKey: .appStoreId)
        self.buildString = try? container.decodeIfPresent(String.self, forKey: .build)
        self.bundleVersion = try? container.decodeIfPresent(String.self, forKey: .bundleVersion)
        self.comparator = (try? container.decode(VersionComparator.self, forKey: .comparing))
            ?? Updates.comparingVersions
        self.minOSRequired = try? container.decode(String.self, forKey: .minOSRequired)
        self.minOptionalAppVersion = try? container.decode(String.self, forKey: .minOptionalAppVersion)
        self.minRequiredAppVersion = try? container.decode(String.self, forKey: .minRequiredAppVersion)
        self.notificationMode = (try? container.decode(NotificationMode.self, forKey: .notificationMode))
            ?? Updates.notifying
        self.releaseNotes = try? container.decode(String.self, forKey: .releaseNotes)
        self.updateType = (try? container.decode(UpdateType.self, forKey: .updateType))
            ?? Updates.updateType
        self.updatingMode = (try? container.decode(UpdatingMode.self, forKey: .updatingMode))
            ?? Updates.updatingMode
        self.latestVersion = try? container.decode(String.self, forKey: .version)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(appStoreId, forKey: .appStoreId)
        try container.encode(buildString, forKey: .build)
        try container.encode(bundleVersion, forKey: .bundleVersion)
        try container.encode(comparator, forKey: .comparing)
        try container.encode(minOSRequired, forKey: .minOSRequired)
        try container.encode(notificationMode, forKey: .notificationMode)
        try container.encode(releaseNotes, forKey: .releaseNotes)
        try container.encode(updatingMode, forKey: .updatingMode)
        try container.encode(latestVersion, forKey: .version)
    }

}

extension ConfigurationResult {

    func mutableCopy(with apiResult: ITunesSearchAPIResult) -> ConfigurationResult {
        let mergedReleaseNotes = apiResult.releaseNotes ?? releaseNotes
        return ConfigurationResult(
            appStoreId: "\(apiResult.trackId)",
            buildString: buildString,
            bundleVersion: bundleVersion,
            comparator: comparator,
            minOptionalAppVersion: minOptionalAppVersion,
            minRequiredAppVersion: minRequiredAppVersion,
            minRequiredOSVersion: apiResult.minimumOsVersion,
            notifying: notificationMode,
            releaseNotes: mergedReleaseNotes,
            updateType: updateType,
            updatingMode: updatingMode,
            latestVersion: apiResult.version
        )
    }

}
