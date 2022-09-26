//
//  VersionJournallingServiceResult.swift
//  Updates
//
//  Created by Ross Butler on 15/04/2020.
//

import Foundation

public struct AppUpdatedResult {
    public let isFirstLaunchFollowingInstall: Bool
    public let isFirstLaunchFollowingUpdate: Bool
    
    public init(isFirstLaunchFollowingInstall: Bool, isFirstLaunchFollowingUpdate: Bool) {
        self.isFirstLaunchFollowingInstall = isFirstLaunchFollowingInstall
        self.isFirstLaunchFollowingUpdate = isFirstLaunchFollowingUpdate
    }
}
