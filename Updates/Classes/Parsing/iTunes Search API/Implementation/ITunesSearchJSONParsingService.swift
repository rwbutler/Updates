//
//  ITunesSearchJSONParsingService.swift
//  Updates
//
//  Created by Ross Butler on 12/31/18.
//

import Foundation

struct ITunesSearchJSONParsingService: ParsingService {
    
    // swiftlint:disable:next type_name
    typealias T = ITunesSearchAPIResult
    
    func parse(_ data: Data) -> Result<ITunesSearchAPIResult, ParsingError> {
        let decoder = JSONDecoder()
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
            let jsonContainer = json as? [String: Any],
            let results = jsonContainer["results"],
            let resultsData = try? JSONSerialization.data(withJSONObject: results) else {
                if let result = (try? decoder.decode([ITunesSearchAPIResult].self, from: data))?.first {
                    return .success(result)
                } else {
                  return .failure(.unexpectedFormat)
                }
        }
        guard let result = (try? decoder.decode([ITunesSearchAPIResult].self, from: resultsData))?.first else {
            return .failure(.unexpectedFormat)
        }
        return .success(result)
    }
    
}
