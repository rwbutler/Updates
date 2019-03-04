//
//  Build.swift
//  Updates
//
//  Created by rossbutler on 2/6/19.
//

import Foundation

struct Build: Codable {
    
    /// A `String` which uniquely identifies this build.
    let identifier: String
    
    /// The Date on which this build was installed.
    let installDate: Date
    
    init(_ identifier: String) {
        self.identifier = identifier
        self.installDate = Date()
    }
    
}
