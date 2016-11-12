//
//  Result.swift
//  PodcastMenu
//
//  Created by Guilherme Rambo on 11/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation

enum Result <T, E: Error> {
    case error(E)
    case success(T)
}
