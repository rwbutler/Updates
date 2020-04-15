//
//  ConfigurationJSONParsingService.swift
//  Updates
//
//  Created by Ross Butler on 1/6/19.
//

import Foundation

struct ConfigurationJSONParsingService: ParsingService {
    func parse(_ data: Data) -> Result<ConfigurationResult, ParsingError> {
        let decoder = JSONDecoder()
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
            let jsonContainer = json as? [String: Any],
            let results = jsonContainer["updates"],
            let resultsData = try? JSONSerialization.data(withJSONObject: results) else {
                if let result = try? decoder.decode(ConfigurationResult.self, from: data) {
                    return .success(result)
                } else {
                    return .failure(.unexpectedFormat)
                }
        }
        guard let result = try? decoder.decode(ConfigurationResult.self, from: resultsData) else {
            return .failure(.unexpectedFormat)
        }
        return .success(result)
    }
    
}
