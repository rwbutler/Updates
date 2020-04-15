//
//  SettingsModel.swift
//  Updates
//
//  Created by Ross Butler on 14/04/2020.
//

import Foundation

enum ConfigurationError: Error {
    case networking
    case parsing(_ error: ParsingError)
}
