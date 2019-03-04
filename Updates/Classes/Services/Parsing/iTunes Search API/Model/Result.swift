//
//  Result.swift
//  Updates
//
//  Created by Ross Butler on 1/9/19.
//

import Foundation

enum Result<T, E: Error> {
    case success(T)
    case failure(E)
}
