//
//  UpdatesResult.swift
//  Updates
//
//  Created by Ross Butler on 1/6/19.
//

import Foundation

public enum UpdatesResult {
    case available(Update)
    case none(AppUpdatedResult)
}

public enum UpdateType: String, Codable {
    case hard
    case soft
}

public struct Update {
    public let appStoreId: String?
    public let appStoreURL: URL?
    public let isUpdated: AppUpdatedResult // whether or not this launch is a new install or update.
    public let newVersionString: String
    public let releaseNotes: String?
    public let shouldNotify: Bool
    public let updateType: UpdateType

    public init(
        appStoreId: String?,
        appStoreURL: URL?,
        isUpdated: AppUpdatedResult,
        newVersionString: String,
        releaseNotes: String?,
        shouldNotify: Bool,
        updateType: UpdateType
    ) {
        self.appStoreId = appStoreId
        self.appStoreURL = appStoreURL
        self.isUpdated = isUpdated
        self.newVersionString = newVersionString
        self.releaseNotes = releaseNotes
        self.shouldNotify = shouldNotify
        self.updateType = updateType
    }
}
