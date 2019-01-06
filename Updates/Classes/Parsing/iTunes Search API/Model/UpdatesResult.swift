//
//  UpdatesResult.swift
//  Updates
//
//  Created by Ross Butler on 1/6/19.
//

import Foundation

struct UpdatesResult {
    let newVersionString: String
    let releaseNotes: String
    let shouldNotifyUser: Bool
    let updateAvailable: Bool
}
