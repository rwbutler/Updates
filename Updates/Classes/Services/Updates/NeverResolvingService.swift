//
//  NeverResolvingService.swift
//  Updates
//
//  Created by Ross Butler on 15/04/2020.
//

import Foundation

struct NeverUpdateResolutionService: UpdateResolutionService {

    private let configuration: ConfigurationResult
    private let journalingService: VersionJournalingService

    init(configuration: ConfigurationResult, journalingService: VersionJournalingService) {
        self.configuration = configuration
        self.journalingService = journalingService
    }

    func checkForUpdates(completion: @escaping (UpdatesResult) -> Void) {
        guard let versionString = configuration.bundleVersion else {
            onMainQueue(completion)(
                .none(
                    AppUpdatedResult(isFirstLaunchFollowingInstall: false, isFirstLaunchFollowingUpdate: false)
                )
            )
            return
        }
        let isUpdated = journalingService.registerBuild(
            versionString: versionString,
            buildString: configuration.buildString,
            comparator: configuration.comparator
        )
        onMainQueue(completion)(
            .none(isUpdated)
        )
    }

}
