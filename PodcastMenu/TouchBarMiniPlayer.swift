//
//  TouchBarMiniPlayer.swift
//  PodcastMenu
//
//  Created by Guilherme Rambo on 30/09/17.
//  Copyright © 2017 Guilherme Rambo. All rights reserved.
//

import Cocoa

@available(OSX 10.12.2, *)
final class TouchBarMiniPlayer: NSTouchBar {
    
    static func instantiate() -> TouchBarMiniPlayer {
        let nibName = String(describing: self)
        
        guard let nib = NSNib(nibNamed: nibName, bundle: nil) else {
            fatalError("Missing required nib \(nibName), bundle is probably damaged")
        }
        
        var nibObjects = NSArray()
        
        guard nib.instantiate(withOwner: nil, topLevelObjects: &nibObjects) else {
            fatalError("Unable to load nib, something is seriously wrong")
        }
        
        return nibObjects.first(where: { $0 is TouchBarMiniPlayer }) as! TouchBarMiniPlayer
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(forName: .OvercastDidPlay, object: nil, queue: .main) { [weak self] _ in
            self?.activateButtonPlayingState()
        }
        NotificationCenter.default.addObserver(forName: .OvercastDidPause, object: nil, queue: .main) { [weak self] _ in
            self?.activateButtonPausedState()
        }
    }
    
    func updateUI(oldInfo: PlaybackInfo?, newInfo: PlaybackInfo?) {
        guard oldInfo != newInfo, nowPlayingController != nil else { return }
        
        playPauseButton.isHidden = (newInfo == nil)
        
        nowPlayingController.updateUI(oldInfo: oldInfo, newInfo: newInfo)
    }
    
    private func activateButtonPausedState() {
        playPauseButton.image = #imageLiteral(resourceName: "play_touchbar")
    }
    
    private func activateButtonPlayingState() {
        playPauseButton.image = #imageLiteral(resourceName: "pause_touchbar")
    }
    
    @IBOutlet weak var touchBarItem: NSGroupTouchBarItem!
    
    @IBOutlet private weak var playPauseButton: NSButton!
    
    @IBOutlet private weak var nowPlayingController: TouchBarNowPlayingController!
    
    @IBAction private func playPauseAction(_ sender: NSButton) {
        NotificationCenter.default.post(name: .OvercastCommandTogglePlaying, object: nil)
    }
    
}
