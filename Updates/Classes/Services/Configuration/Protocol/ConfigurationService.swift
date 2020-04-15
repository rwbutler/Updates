//
//  ConfigurationService.swift
//  Updates
//
//  Created by Ross Butler on 15/04/2020.
//

import Foundation

protocol ConfigurationService {
    func fetchSettings(_ completion: @escaping (ConfigurationServiceResult) -> Void)
}
