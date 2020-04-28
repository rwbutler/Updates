//
//  VersionJournallingService.swift
//  Updates
//
//  Created by Ross Butler on 15/04/2020.
//

import Foundation

protocol VersionJournalingService {
    func registerBuild(versionString: String, buildString: String, comparator: VersionComparator) ->
    VersionJournalingServiceResult
}
