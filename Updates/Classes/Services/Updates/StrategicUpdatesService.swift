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
    private let configuration: ConfigurationResult
    private let journalingService: VersionJournalingService
    private let operatingSystemVersion: String
    private let strategy: UpdateCheckingStrategy

    init(
        appMetadataService: AppMetadataService? = nil,
        configuration: ConfigurationResult,
        journalingService: VersionJournalingService,
        operatingSystemVersion: String,
        strategy: UpdateCheckingStrategy
    ) {
        self.appMetadataService = appMetadataService
        self.configuration = configuration
        self.journalingService = journalingService
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
                    configuration: configuration,
                    journalingService: journalingService,
                    operatingSystemVersion: self.operatingSystemVersion
                )
            } else {
                updatesService = ManualUpdateResolutionService(
                    configuration: configuration,
                    journalingService: journalingService,
                    operatingSystemVersion: operatingSystemVersion
                )
            }
        case .manually:
            updatesService = ManualUpdateResolutionService(
                configuration: configuration,
                journalingService: journalingService,
                operatingSystemVersion: operatingSystemVersion
            )
        case .never:
            updatesService = NeverUpdateResolutionService(
                configuration: configuration,
                journalingService: journalingService
            )
        }
        updatesService.checkForUpdates(completion: completion)
    }
}
