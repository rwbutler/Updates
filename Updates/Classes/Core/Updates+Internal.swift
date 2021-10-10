//
//  Updates+Internal.swift
//  Updates
//
//  Created by Ross Butler on 3/4/19.
//

import Foundation

extension Updates {
    
    /// Returns the URL to open the app with the specified identifier in the App Store.
    /// - Parameters:
    ///     - appStoreId: The app store identifier specified as a String.
    /// - Returns: The URL required to launch the App Store page for the specified app,
    /// provided a valid identifier is provided.
    static func appStoreURL(appStoreId: String, countryCode: String? = nil, productName: String? = nil) -> URL? {
        guard let countryCode = countryCode ?? Updates.countryCode, let productName = productName else {
            return nil
        }
        let lowercasedCountryCode = countryCode.lowercased()
        let lowercasedProductName = productName.lowercased()
        let urlString = "https://itunes.apple.com/\(lowercasedCountryCode)/app/\(lowercasedProductName)/id\(appStoreId)"
        return URL(string: urlString)
    }
    
    static func bundledConfigurationURL(_ configType: ConfigurationType = Updates.configurationType) -> URL? {
        return Bundle.main.url(forResource: configurationName, withExtension: configType.rawValue)
    }
    
    static var cachedConfigurationURL: URL? {
        return try? FileManager.default
            .url(for: .cachesDirectory,
                 in: .userDomainMask,
                 appropriateFor: nil,
                 create: true)
            .appendingPathComponent("\(configurationName).\(configurationType.rawValue)")
    }
    
    /**
     Compares two semantic version numbers.
     - parameter lhs: First semantic version number.
     - parameter rhs: Second semantic version number.
     - returns: .orderedSame if versions are equal, .orderedAscending if lhs is earlier than rhs
     and orderedDescending if rhs is earlier than lhs.
     */
    static func compareVersions(
        lhs: String,
        lhsBuildNumber: String? = nil,
        rhs: String,
        rhsBuildNumber: String? = nil,
        comparator: VersionComparator
    ) -> ComparisonResult {
        let semanticVersioningComponents: [VersionComparator] = [.major, .minor, .patch, .build]
        var result = ComparisonResult.orderedSame
        var lhsComponents = lhs.components(separatedBy: ".")
        var rhsComponents = rhs.components(separatedBy: ".")
        
        // Pad out the array to make equal in length
        lhsComponents = padLHSWithZeroes(lhs: lhsComponents, rhs: rhsComponents)
        rhsComponents = padLHSWithZeroes(lhs: rhsComponents, rhs: lhsComponents)
        // If comparator is `.build` add the build number as an additional component and compare.
        if comparator == .build, let lhsBuildNumber = lhsBuildNumber, let rhsBuildNumber = rhsBuildNumber {
            if lhsComponents.count > semanticVersioningComponents.count,
               rhsComponents.count > semanticVersioningComponents.count {
                // Number of components greater than expected therefore
                // build number may have already been added as a component.
                lhsComponents[3] = lhsBuildNumber
                rhsComponents[3] = rhsBuildNumber
            } else {
                lhsComponents.append(lhsBuildNumber)
                rhsComponents.append(rhsBuildNumber)
            }
        }
        // If comparator is a value not present in the array e.g. .major + .patch then fallback to comparing
        // individual components and ignore comparator.
        guard semanticVersioningComponents.contains(comparator) else {
            for (lhsComponent, rhsComponent) in zip(lhsComponents, rhsComponents) {
                result = comparisonResult(lhs: lhsComponent, rhs: rhsComponent)
                if result != .orderedSame {
                    break
                }
            }
            return result
        }
        var counter = 0
        for (lhsComponent, rhsComponent) in zip(lhsComponents, rhsComponents) {
            guard counter < semanticVersioningComponents.count else {
                break
            }
            let semanticComponent = semanticVersioningComponents[counter]
            guard semanticComponent.rawValue <= comparator.rawValue else {
                break
            }
            result = comparisonResult(lhs: lhsComponent, rhs: rhsComponent)
            if result != .orderedSame {
                break
            }
            counter += 1
        }
        return result
    }
    
    static func comparisonResult(lhs: Int, rhs: Int) -> ComparisonResult {
        var result = ComparisonResult.orderedSame
        if lhs < rhs {
            result = ComparisonResult.orderedAscending
        } else if lhs > rhs {
            result = ComparisonResult.orderedDescending
        }
        return result
    }
    
    static func comparisonResult(lhs: String, rhs: String) -> ComparisonResult {
        var result: ComparisonResult = .orderedSame
        if let lhsComponent = Int(lhs), let rhsComponent = Int(rhs) {
            result = comparisonResult(lhs: lhsComponent, rhs: rhsComponent)
        } else if lhs < rhs {
            result = .orderedAscending
        } else if lhs > rhs {
            result = .orderedDescending
        }
        return result
    }
    
    static let configurationName: String = "Updates"
    
    /// Pads out LHS array with zeroes
    static func padLHSWithZeroes(lhs: [String], rhs: [String]) -> [String] {
        var result = lhs
        while result.count < rhs.count {
            result.append("0")
        }
        return result
    }

}
