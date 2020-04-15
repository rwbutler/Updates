//
//  NeverResolvingService.swift
//  Updates
//
//  Created by Ross Butler on 15/04/2020.
//

import Foundation

struct NeverUpdateResolutionService: UpdateResolutionService {
    
    func checkForUpdates(completion: @escaping (UpdatesResult) -> Void) {
        onMainQueue(completion)(.none)
    }
    
}
