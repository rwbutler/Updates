//
//  AppMetadataService.swift
//  Updates
//
//  Created by Ross Butler on 09/04/2020.
//

import Foundation

typealias AppMetadataResult = Result<ITunesSearchAPIResult, ParsingError>

protocol AppMetadataService {
    func fetchAppMetadata(_ completion: @escaping (AppMetadataResult) -> Void)
}
