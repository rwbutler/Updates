//
//  MainQueueAdditions.swift
//  Updates
//
//  Created by Ross Butler on 13/04/2020.
//

import Foundation

func onMainQueue<U>(_ block: @escaping (U) -> Void) -> ((U) -> Void) {
    return { (argBlock: U) -> Void in
        DispatchQueue.main.async {
            block(argBlock)
        }
    }
}
