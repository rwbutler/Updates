//
//  ConfigurationService.swift
//  Updates
//
//  Created by Ross Butler on 15/04/2020.
//

import Foundation

protocol ConfigurationService {
    func fetchSettings(defaults: ConfigurationResult, completion: @escaping (ConfigurationServiceResult) -> Void)
}
