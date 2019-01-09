//
//  ParsingService.swift
//  Updates
//
//  Created by Ross Butler on 12/31/18.
//

import Foundation

protocol ParsingService {
    
    // swiftlint:disable:next type_name
    associatedtype T
    func parse(_ data: Data) -> Result<T, ParsingError>
    
}
