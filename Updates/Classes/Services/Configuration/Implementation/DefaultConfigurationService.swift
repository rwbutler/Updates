//
//  DefaultConfigurationService.swift
//  Updates
//
//  Created by Ross Butler on 15/04/2020.
//

import Foundation

struct DefaultConfigurationService: ConfigurationService {

    private let cachedConfigurationURL: URL
    private let configurationURL: URL
    private let parsingService = ConfigurationJSONParsingService()

    init(configurationURL: URL, cachedConfigurationURL: URL) {
        self.cachedConfigurationURL = cachedConfigurationURL
        self.configurationURL = configurationURL
    }

    /// Asynchronously fetches confguration settings.
    func fetchSettings(defaults: ConfigurationResult, completion: @escaping (ConfigurationServiceResult) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let settings = self.fetchSettings(configurationURL: self.configurationURL, defaults: defaults)
            onMainQueue(completion)(settings)
        }
    }

}

private extension DefaultConfigurationService {

    private func cacheConfiguration(_ result: ConfigurationResult) {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(result) else {
            return
        }
        try? data.write(to: cachedConfigurationURL)
    }

    /// Synchronously fetches settings from the given URL.
    private func fetchSettings(configurationURL: URL, defaults: ConfigurationResult) -> ConfigurationServiceResult {
        guard let configurationData = try? Data(contentsOf: configurationURL) else {
            return .failure(.networking)
        }
        let parsingResult = parsingService.parse(configurationData)
        switch parsingResult {
        case .success(let result):
            let configuration = merge(result: result, defaults: defaults)
            if configurationURL != cachedConfigurationURL {
                cacheConfiguration(configuration)
            }
            return .success(configuration)
        case .failure(let error):
            guard configurationURL != cachedConfigurationURL else {
                return .failure(.parsing(error))
            }
            return fetchSettings(configurationURL: cachedConfigurationURL, defaults: defaults)
        }
    }

    /// Fills in any information missing from Updates.json with programmatically configured default values.
    private func merge(result: ConfigurationResult, defaults: ConfigurationResult) -> ConfigurationResult {
        return ConfigurationResult(
            appStoreId: result.appStoreId ?? defaults.appStoreId,
            buildString: result.buildString ?? defaults.buildString,
            bundleVersion: result.bundleVersion ?? defaults.bundleVersion,
            comparator: result.comparator,
            minOptionalAppVersion: result.minOptionalAppVersion ?? defaults.minOptionalAppVersion,
            minRequiredAppVersion: result.minRequiredAppVersion ?? defaults.minRequiredAppVersion,
            minRequiredOSVersion: result.minOSRequired ?? defaults.minOSRequired,
            notifying: result.notificationMode,
            releaseNotes: result.releaseNotes ?? defaults.releaseNotes,
            updateType: result.updateType,
            updatingMode: result.updatingMode,
            latestVersion: result.latestVersion ?? defaults.latestVersion
        )
    }

}
