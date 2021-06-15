//
//  VersionJournallingService.swift
//  Updates
//
//  Created by Ross Butler on 15/04/2020.
//

import Foundation

protocol VersionJournalingService {
    func incrementNotificationCount(for version: String)
    func notificationCount(for version: String) -> Int
    func registerBuild(versionString: String, buildString: String?, comparator: VersionComparator) ->
    AppUpdatedResult
}
