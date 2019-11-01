//
//  Updates+UIDevice.swift
//  Updates
//
//  Created by Ross Butler on 8/8/19.
//

import Foundation
import UIKit

public extension Updates {
    
    static func checkForUpdates(completion: @escaping (UpdatesResult) -> Void) {
        Updates.checkForUpdates(currentOSVersion: UIDevice.current.systemVersion, completion: completion)
    }
    
    static func checkForUpdates(_ mode: UpdatingMode = Updates.updatingMode,
                                comparingVersions comparator: VersionComparator = Updates.comparingVersions,
                                notifying: NotificationMode = Updates.notifying,
                                releaseNotes: String? = nil,
                                completion: @escaping (UpdatesResult) -> Void) {
        checkForUpdates(mode, comparingVersions: comparator, currentOSVersion: UIDevice.current.systemVersion,
                        notifying: notifying, releaseNotes: releaseNotes, completion: completion)
    }
    
}
