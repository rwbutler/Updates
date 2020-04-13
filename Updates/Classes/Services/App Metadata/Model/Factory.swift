//
//  Factory.swift
//  Updates
//
//  Created by Ross Butler on 12/04/2020.
//

import Foundation

protocol Factory {
    associatedtype Result
    func manufacture() -> Result
}
