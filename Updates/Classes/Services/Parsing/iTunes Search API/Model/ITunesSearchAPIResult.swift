//
//  Result.swift
//  Updates
//
//  Created by Ross Butler on 12/31/18.
//

import Foundation

public struct ITunesSearchAPIResult: Codable {
    let minimumOsVersion: String
    let releaseNotes: String?
    let trackId: Int
    let version: String
}
