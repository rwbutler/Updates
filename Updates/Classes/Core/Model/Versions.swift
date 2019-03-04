//
//  Versions.swift
//  Updates
//
//  Created by Ross Butler on 2/6/19.
//

import Foundation

struct Versions: Codable {
    
    typealias SortOptions = VersionSortOptions
    
    private var versions: [Version] = []
    
    @discardableResult
    mutating func appendVersion(versionIdentifier: String, buildIdentifier: String) -> Version {
        guard var existingVersion = version(versionIdentifier) else {
            let newVersion = Version(versionIdentifier, buildIdentifier: buildIdentifier)
            versions.append(newVersion)
            return newVersion
        }
        existingVersion.appendBuild(buildIdentifier)
        return existingVersion
    }
    
    func versionExists(versionIdentifier: String, comparator: VersionComparator) -> Bool {
        // TODO: Implement comparator.
        let existingVersion = version(versionIdentifier)
        return existingVersion != nil
    }
    
    func buildExists(versionIdentifier: String, buildIdentifier: String) -> Bool {
        let existingVersion = version(versionIdentifier)
        return existingVersion?.buildExists(buildIdentifier) ?? false
    }
    
    func latestVersion(by sortOptions: SortOptions = .installDate) -> Version? {
        let sorted = versions.sorted(by: { (lhs, rhs) in
            switch sortOptions {
            case .identifier:
                return lhs.identifier < rhs.identifier
            case .installDate:
                let lhsLatestBuild = lhs.latestBuild(by: sortOptions)
                let rhsLatestBuild = rhs.latestBuild(by: sortOptions)
                return lhsLatestBuild.installDate < rhsLatestBuild.installDate
            }
        })
        return sorted.last
    }
    
    private func version(_ versionIdentifier: String) -> Version? {
        let existingVersion = versions.first(where: { version in
            version.identifier == versionIdentifier
        })
        return existingVersion
    }
}
