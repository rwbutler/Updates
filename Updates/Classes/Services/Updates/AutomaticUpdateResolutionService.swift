//
//  AutomaticUpdateResolutionService.swift
//  Updates
//
//  Created by Ross Butler on 15/04/2020.
//

import Foundation

struct AutomaticUpdateResolutionService: UpdateResolutionService {

    private let appMetadataService: AppMetadataService
    private let configuration: ConfigurationResult
    private let journalingService: VersionJournalingService
    private let operatingSystemVersion: String

    init(
        appMetadataService: AppMetadataService,
        configuration: ConfigurationResult,
        journalingService: VersionJournalingService,
        operatingSystemVersion: String
    ) {
        self.appMetadataService = appMetadataService
        self.configuration = configuration
        self.journalingService = journalingService
        self.operatingSystemVersion = operatingSystemVersion
    }

    func checkForUpdates(completion: @escaping (UpdatesResult) -> Void) {
        DispatchQueue.global(qos: .background).async {
            self.appMetadataService.fetchAppMetadata { result in
                switch result {
                case .success(let apiResult):
                    let updatedConfiguration = self.configuration.mutableCopy(with: apiResult)
                    let factory = UpdatesResultFactory(
                        configuration: updatedConfiguration,
                        journalingService: journalingService,
                        operatingSystemVersion: self.operatingSystemVersion
                    )
                    onMainQueue(completion)(factory.manufacture())
                case .failure:
                    guard let versionString = self.configuration.bundleVersion else {
                        onMainQueue(completion)(
                            .none(
                                AppUpdatedResult(
                                    isFirstLaunchFollowingInstall: false,
                                    isFirstLaunchFollowingUpdate: false
                                )
                            )
                        )
                        return
                    }
                    let isUpdated = journalingService.registerBuild(
                        versionString: versionString,
                        buildString: configuration.buildString,
                        comparator: configuration.comparator
                    )
                    onMainQueue(completion)(.none(isUpdated))
                }
            }
        }
    }

}
