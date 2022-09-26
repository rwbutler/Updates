//
//  NotificationMode.swift
//  Updates
//
//  Created by Ross Butler on 12/28/18.
//

import Foundation

public enum NotificationMode: String, Codable {
    case never
    case once
    case twice
    case thrice
    case always
    case withoutAvailableUpdate = "without-available-update"

    var notificationCount: Int {
        switch self {
        case .never:
            return 0
        case .once:
            return 1
        case .twice:
            return 2
        case .thrice:
            return 3
        case .always, .withoutAvailableUpdate:
            return Int.max
        }
    }
}
