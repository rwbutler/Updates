//
//  ManualUpdateResolutionService.swift
//  Updates
//
//  Created by Ross Butler on 15/04/2020.
//

import Foundation

struct ManualUpdateResolutionService: UpdateResolutionService {
    
    private let bundleVersion: String
    private let configuration: ConfigurationResult
    private let operatingSystemVersion: String
    
    init(configuration: ConfigurationResult, bundleVersion: String, operatingSystemVersion: String) {
        self.bundleVersion = bundleVersion
        self.configuration = configuration
        self.operatingSystemVersion = operatingSystemVersion
    }
    
    func checkForUpdates(completion: @escaping (UpdatesResult) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let factory = UpdatesResultFactory(
                configuration: self.configuration,
                bundleVersion: self.bundleVersion,
                operatingSystemVersion: self.operatingSystemVersion
            )
            onMainQueue(completion)(factory.manufacture())
        }
    }
    
}
