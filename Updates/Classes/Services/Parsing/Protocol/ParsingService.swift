//
//  ParsingService.swift
//  Updates
//
//  Created by Ross Butler on 12/31/18.
//

import Foundation

protocol ParsingService {
    associatedtype ParsedModel
    func parse(_ data: Data) -> Result<ParsedModel, ParsingError>
}
