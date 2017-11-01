//
//  TouchBarNowPlayingController.swift
//  PodcastMenu
//
//  Created by Guilherme Rambo on 30/09/17.
//  Copyright © 2017 Guilherme Rambo. All rights reserved.
//

import Cocoa

class TouchBarNowPlayingController: NSViewController {

    @IBOutlet private weak var artworkImageView: NSImageView!
    @IBOutlet private weak var titleLabel: NSTextField!
    @IBOutlet private weak var timeRemainingLabel: NSTextField!
    
    func updateUI(oldInfo: PlaybackInfo?, newInfo: PlaybackInfo?) {
        let hide = (newInfo == nil)
        
        artworkImageView.isHidden = hide
        titleLabel.isHidden = hide
        timeRemainingLabel.isHidden = hide
        
        let title = newInfo?.title ?? ""
        let timeRemaining = newInfo?.timeRemaining ?? ""
        
        titleLabel.stringValue = title
        timeRemainingLabel.stringValue = "-\(timeRemaining)"
        
        guard oldInfo?.artworkURL != newInfo?.artworkURL else { return }
        
        guard let artworkURL = newInfo?.artworkURL else {
            artworkImageView.image = nil
            return
        }
        
        updateArtwork(with: artworkURL)
    }
    
    private func updateArtwork(with url: URL) {
        _ = ImageCache.shared.fetchImage(at: url, completion: { [weak self] (requestedURL, image) in
            guard requestedURL == url else { return }
            
            self?.artworkImageView.image = image
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
