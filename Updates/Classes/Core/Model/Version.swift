//
//  Version.swift
//  Updates
//
//  Created by Ross Butler on 2/6/19.
//

import Foundation

struct Version: Codable {
    
    typealias SortOptions = VersionSortOptions
    
    private var builds: [Build] = []
    let identifier: String
    
    init(_ identifier: String, buildIdentifier: String) {
        self.identifier = identifier
        appendBuild(buildIdentifier)
    }
    
    @discardableResult
    mutating func appendBuild(_ buildIdentifier: String) -> Build {
        let existingBuild = builds.first(where: { build in
            build.identifier == buildIdentifier
        })
        guard let build = existingBuild else {
            let newBuild = Build(buildIdentifier)
            builds.append(newBuild)
            return newBuild
        }
        return build
    }
    
    func buildExists(_ buildIdentifier: String) -> Bool {
        let existingBuild = builds.first(where: { build in
            build.identifier == buildIdentifier
        })
        return existingBuild != nil
    }
    
    func latestBuild(by sortOptions: SortOptions = .installDate) -> Build {
        let sorted = builds.sorted(by: { (lhs, rhs) in
            switch sortOptions {
            case .identifier:
                return lhs.identifier < rhs.identifier
            case .installDate:
                return lhs.installDate < rhs.installDate
            }
        })
        assert(!sorted.isEmpty, "Initializer does not allow a new version without an accompanying build number.")
        return sorted.last!
    }
    
}
