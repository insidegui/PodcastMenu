//
//  TouchBarController.swift
//  PodcastMenu
//
//  Created by Guilherme Rambo on 12/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa

class TouchBarController: NSObject {

    var episodes: [Episode] = [] {
        didSet {
            DispatchQueue.main.async {
                print(self.episodes)
            }
        }
    }
    
    var podcasts: [Podcast] = [] {
        didSet {
            DispatchQueue.main.async {
                print(self.podcasts)
            }
        }
    }
    
}
