//
//  Services.swift
//  Updates
//
//  Created by Ross Butler on 12/04/2020.
//

import Foundation

struct Services {

    static func appMetadata(bundleIdentifier: String, countryCode: String) -> AppMetadataService? {
        return ITunesSearchAPIService(bundleIdentifier: bundleIdentifier, countryCode: countryCode)
    }

    static func configuration(configurationURL: URL, cachedConfigurationURL: URL) -> ConfigurationService {
        return DefaultConfigurationService(
            configurationURL: configurationURL,
            cachedConfigurationURL: cachedConfigurationURL
        )
    }

    static var journaling: VersionJournalingService {
        DefaultVersionJournalingService()
    }

    static func updateResolutionService(
        appMetadataService: AppMetadataService? = nil,
        configuration: ConfigurationResult,
        operatingSystemVersion: String,
        strategy: UpdatingMode
    ) -> UpdateResolutionService {
        return StrategicUpdateResolutionService(
            appMetadataService: appMetadataService,
            configuration: configuration,
            journalingService: journaling,
            operatingSystemVersion: operatingSystemVersion,
            strategy: strategy
        )
    }

}
