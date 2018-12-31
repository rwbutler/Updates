//
//  JSONParsingService.swift
//  Updates
//
//  Created by Ross Butler on 12/31/18.
//

import Foundation

struct JSONParsingService: ParsingService {
    
    func parse(_ data: Data) -> ParsingServiceResult? {
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
            let jsonContainer = json as? [String: Any],
            let results = jsonContainer["results"],
            let resultsData = try? JSONSerialization.data(withJSONObject: results) else {
                let decoder = JSONDecoder()
                return (try? decoder.decode([Result].self, from: data))?.first
        }
        let decoder = JSONDecoder()
        guard let result = try? decoder.decode([Result].self, from: resultsData).first else {
            return nil
        }
        return result
    }
    
}
