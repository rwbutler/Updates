//
//  UpdatesResult.swift
//  Updates
//
//  Created by Ross Butler on 1/6/19.
//

import Foundation

public enum UpdatesResult {
    case available(Update)
    case none
}

public struct Update {
    public let newVersionString: String
    public let releaseNotes: String?
    public let shouldNotify: Bool
}
