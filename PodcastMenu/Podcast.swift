//
//  Podcast.swift
//  PodcastMenu
//
//  Created by Guilherme Rambo on 11/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation

struct Podcast: Equatable {
    
    let name: String
    let poster: URL
    let link: URL?
    
    static func == (lhs: Podcast, rhs: Podcast) -> Bool {
        return lhs.name == rhs.name && lhs.poster == rhs.poster && lhs.link == rhs.link
    }
}
