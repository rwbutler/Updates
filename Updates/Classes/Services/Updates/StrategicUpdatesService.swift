//
//  StrategicUpdatesService.swift
//  Updates
//
//  Created by Ross Butler on 13/04/2020.
//

import Foundation

struct StrategicUpdateResolutionService: UpdateResolutionService {
    
    typealias UpdateCheckingStrategy = UpdatingMode
    private let appMetadataService: AppMetadataService?
    private let bundleVersion: String
    private let configuration: ConfigurationResult
    private let operatingSystemVersion: String
    private let strategy: UpdateCheckingStrategy
    
    init(appMetadataService: AppMetadataService? = nil, bundleVersion: String,
         configuration: ConfigurationResult, operatingSystemVersion: String,
         strategy: UpdateCheckingStrategy) {
        self.appMetadataService = appMetadataService
        self.bundleVersion = bundleVersion
        self.configuration = configuration
        self.operatingSystemVersion = operatingSystemVersion
        self.strategy = strategy
    }
    
    func checkForUpdates(completion: @escaping (UpdatesResult) -> Void) {
        let updatesService: UpdateResolutionService
        switch strategy {
        case .automatically:
            if let appMetadataService = appMetadataService {
                updatesService = AutomaticUpdateResolutionService(
                    appMetadataService: appMetadataService,
                    bundleVersion: bundleVersion,
                    configuration: configuration,
                    operatingSystemVersion: self.operatingSystemVersion
                )
            } else {
                updatesService = ManualUpdateResolutionService(
                    configuration: configuration,
                    bundleVersion: bundleVersion,
                    operatingSystemVersion: operatingSystemVersion
                )
            }
        case .manually:
            updatesService = ManualUpdateResolutionService(
                configuration: configuration,
                bundleVersion: bundleVersion,
                operatingSystemVersion: operatingSystemVersion
            )
        case .never:
            updatesService = NeverUpdateResolutionService()
        }
        updatesService.checkForUpdates(completion: completion)
    }
}
