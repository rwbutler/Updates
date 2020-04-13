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
    
}
