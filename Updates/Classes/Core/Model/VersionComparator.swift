//
//  Versions.swift
//  Updates
//
//  Created by Ross Butler on 12/28/18.
//

import Foundation

public struct VersionComparator: OptionSet, Codable {
    
    public let rawValue: Int
    public static let major = VersionComparator(rawValue: 1 << 0)
    public static let minor = VersionComparator(rawValue: 1 << 1)
    public static let patch = VersionComparator(rawValue: 1 << 2)
    public static let build = VersionComparator(rawValue: 1 << 3) // Currently not supported

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
}

extension VersionComparator {
    public init(optionsString: String) {
        var result: VersionComparator = []
        let allOptions: [String: VersionComparator] = ["major-versions": VersionComparator.major,
                                              "minor-versions": VersionComparator.minor,
                                              "patch-versions": VersionComparator.patch,
                                              "build-versions": VersionComparator.build]
        let options = optionsString.split(separator: ",").map { String($0) }
        for (key, value) in allOptions {
            if options.contains(key) {
                result.update(with: value)
            }
        }
        self = result
    }
}

extension VersionComparator: Comparable {
    public static func < (lhs: VersionComparator, rhs: VersionComparator) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
