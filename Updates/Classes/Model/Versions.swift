//
//  Versions.swift
//  Updates
//
//  Created by Ross Butler on 12/28/18.
//

import Foundation

public struct Versions: OptionSet {
    
    public let rawValue: Int
    public static let major = Versions(rawValue: 1 << 0)
    public static let minor = Versions(rawValue: 1 << 1)
    public static let patch = Versions(rawValue: 1 << 2)
    public static let build = Versions(rawValue: 1 << 3)
    public static let semantic: Versions = [.major, .minor, .patch]
    public static let all: Versions = [.major, .minor, .patch, .build]

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
}

extension Versions {
    
    public init(optionsString: String) {
        var result: Versions = []
        let allOptions: [String: Versions] = ["major-versions": Versions.major,
                                              "minor-versions": Versions.minor,
                                              "patch-versions": Versions.patch,
                                              "semantic-versions": Versions.semantic,
                                              "all-versions": Versions.all]
        let options = optionsString.split(separator: ",").map { String($0) }
        for (key, value) in allOptions {
            if options.contains(key) {
                result.update(with: value)
            }
        }
        self = result
    }
    
}
