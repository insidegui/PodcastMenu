//
//  Constants.swift
//  PodcastMenu
//
//  Created by Guilherme Rambo on 10/05/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation

struct Constants {
    static let allowedHosts = ["overcast.fm","www.overcast.fm"]
    static let webAppURL = URL(string: "https://overcast.fm/podcasts")!
    static let javascriptBridgeName = "PodcastMenuApp"
    static let maxLoudness = 128.0
    static let retryIntervalAfterError = 10.0
    static let homeTitle = "Overcast"
    static let homePath = "/podcasts"
    static let logOutURL = URL(string: "https://overcast.fm/logout")!
}
