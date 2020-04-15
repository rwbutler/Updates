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
    
}
