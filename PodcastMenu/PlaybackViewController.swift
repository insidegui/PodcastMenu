//
//  PlaybackViewController.swift
//  PodcastMenu
//
//  Created by Guilherme Rambo on 01/10/17.
//  Copyright © 2017 Guilherme Rambo. All rights reserved.
//

import Cocoa

final class PlaybackViewController: NSViewController {

    var playbackURL: URL? {
        didSet {
            guard oldValue != playbackURL else { return }
            
            play()
        }
    }
    
    static func instantiate() -> PlaybackViewController {
        let storyboard = NSStoryboard(name: "Playback", bundle: nil)
        
        return storyboard.instantiateInitialController() as! PlaybackViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
    }
    
    @objc func play() {
        guard let url = playbackURL else { return }
        
        PlaybackManager.shared.play(from: url)
    }
    
    @objc func pause() {
        PlaybackManager.shared.pause()
    }
    
}
