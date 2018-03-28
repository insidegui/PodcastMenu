//
//  Episode.swift
//  PodcastMenu
//
//  Created by Guilherme Rambo on 11/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation

struct Episode: Equatable {
    
    enum Time {
        case duration(String)
        case remaining(String)
    }
    
    let podcast: Podcast
    let title: String
    let poster: URL
    let date: Date
    let time: Time
    let link: URL?
    
    static func == (lhs: Episode, rhs: Episode) -> Bool {
        return lhs.podcast == rhs.podcast && lhs.title == rhs.title && lhs.date == rhs.date
    }
    
}
