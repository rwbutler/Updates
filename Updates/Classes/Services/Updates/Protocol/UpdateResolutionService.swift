//
//  UpdatesResolutionService.swift
//  Updates
//
//  Created by Ross Butler on 15/04/2020.
//

import Foundation

protocol UpdateResolutionService {
    func checkForUpdates(completion: @escaping (UpdatesResult) -> Void)
}
