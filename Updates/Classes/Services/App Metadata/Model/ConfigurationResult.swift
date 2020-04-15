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
        case comparing
        case minOSRequired = "min-os-required"
        case notificationMode = "notify"
        case releaseNotes = "release-notes"
        case updatingMode = "check-for"
        case version
    }
    
    let appStoreId: String?
    let buildString: String?
    let comparator: VersionComparator
    let minOSRequired: String?
    let notificationMode: NotificationMode
    let releaseNotes: String?
    let updatingMode: UpdatingMode
    let version: String?
    
    init(appStoreId: String?, build: String?, comparator: VersionComparator, minRequiredOSVersion: String?,
         notifying: NotificationMode, releaseNotes: String?, updatingMode: UpdatingMode, version: String?) {
        self.appStoreId = appStoreId
        self.buildString = build
        self.comparator = comparator
        self.minOSRequired = minRequiredOSVersion
        self.notificationMode = notifying
        self.releaseNotes = releaseNotes
        self.updatingMode = updatingMode
        self.version = version
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.appStoreId = try? container.decode(String.self, forKey: .appStoreId)
        self.buildString = try? container.decode(String.self, forKey: .build)
        self.comparator = (try? container.decode(VersionComparator.self, forKey: .comparing)) ?? .patch
        self.minOSRequired = try? container.decode(String.self, forKey: .minOSRequired)
        self.notificationMode = (try? container.decode(NotificationMode.self, forKey: .notificationMode)) ?? .once
        self.releaseNotes = try? container.decode(String.self, forKey: .releaseNotes)
        self.updatingMode = (try? container.decode(UpdatingMode.self, forKey: .updatingMode)) ?? .automatically
        self.version = try? container.decode(String.self, forKey: .version)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(appStoreId, forKey: .appStoreId)
        try container.encode(buildString, forKey: .build)
        try container.encode(comparator, forKey: .comparing)
        try container.encode(minOSRequired, forKey: .minOSRequired)
        try container.encode(notificationMode, forKey: .notificationMode)
        try container.encode(releaseNotes, forKey: .releaseNotes)
        try container.encode(updatingMode, forKey: .updatingMode)
        try container.encode(version, forKey: .version)
    }
    
}

extension ConfigurationResult {
    
    func mutableCopy(with apiResult: ITunesSearchAPIResult) -> ConfigurationResult {
        let mergedReleaseNotes = apiResult.releaseNotes ?? releaseNotes
        return ConfigurationResult(
            appStoreId: "\(apiResult.trackId)",
            build: buildString,
            comparator: comparator,
            minRequiredOSVersion: apiResult.minimumOsVersion,
            notifying: notificationMode,
            releaseNotes: mergedReleaseNotes,
            updatingMode: updatingMode,
            version: apiResult.version
        )
    }
    
}
