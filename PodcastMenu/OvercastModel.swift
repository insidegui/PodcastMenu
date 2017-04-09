//
//  OvercastModel.swift
//  PodcastMenu
//
//  Created by Guilherme Rambo on 09/04/17.
//  Copyright © 2017 Guilherme Rambo. All rights reserved.
//

import Foundation

protocol OvercastModel {
    
    var title: String { get }
    var link: URL? { get }
    var poster: URL { get }
    
}

extension Podcast: OvercastModel {
    
    var title: String {
        return name
    }
    
}

extension Episode: OvercastModel { }

extension OvercastModel {
    
    func compare(to other: OvercastModel) -> Bool {
        return self.title == other.title && self.link == other.link && self.poster == other.poster
    }
    
}
