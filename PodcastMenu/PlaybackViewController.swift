//
//  PlaybackViewController.swift
//  PodcastMenu
//
//  Created by Guilherme Rambo on 01/10/17.
//  Copyright © 2017 Guilherme Rambo. All rights reserved.
//

import Cocoa

final class PlaybackViewController: NSViewController {

    static func instantiate() -> PlaybackViewController {
        let storyboard = NSStoryboard(name: "Playback", bundle: nil)
        
        return storyboard.instantiateInitialController() as! PlaybackViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
