//
//  Adapter.swift
//  PodcastMenu
//
//  Created by Guilherme Rambo on 11/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation

enum AdapterError: Error {
    case notImplemented
    case missingRequiredFields
}

class Adapter<I, O> {
    
    var input: I
    
    required init(input: I) {
        self.input = input
    }
    
    func adapt() -> Result<O, AdapterError> {
        return Result.error(.notImplemented)
    }
    
}
