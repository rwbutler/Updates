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
    
    init(configurationURL: URL, cachedConfigurationURL: URL) {
        self.cachedConfigurationURL = cachedConfigurationURL
        self.configurationURL = configurationURL
    }
    
    /// Asynchronously fetches confguration settings.
    func fetchSettings(_ completion: @escaping (ConfigurationServiceResult) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let settings = self.fetchSettings(configurationURL: self.configurationURL)
            onMainQueue(completion)(settings)
        }
    }
    
    /// Synchronously fetches settings from the given URL.
    private func fetchSettings(configurationURL: URL) -> ConfigurationServiceResult {
        guard let configurationData = try? Data(contentsOf: configurationURL) else {
            return .failure(.networking)
        }
        let parsingResult = ConfigurationJSONParsingService().parse(configurationData)
        switch parsingResult {
        case .success(let configuration):
            return .success(configuration)
        case .failure(let error):
            guard configurationURL != cachedConfigurationURL else {
                return .failure(.parsing(error))
            }
            return fetchSettings(configurationURL: cachedConfigurationURL)
        }
    }
    
}
