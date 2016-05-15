//
//  MediaKeysHandler.swift
//  PodcastMenu
//
//  Created by Guilherme Rambo on 10/05/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa

class MediaKeysHandler: NSObject {

    var playPauseHandler = {}
    var forwardHandler = {}
    var backwardHandler = {}
    
    override init() {
        super.init()
        
        startEventTap()
    }
    
    @objc private func playPressed() {
        dispatch_async(dispatch_get_main_queue(), playPauseHandler)
    }
    
    @objc private func forwardPressed() {
        dispatch_async(dispatch_get_main_queue(), forwardHandler)
    }
    
    @objc private func backwardPressed() {
        dispatch_async(dispatch_get_main_queue(), backwardHandler)
    }
    
    // MARK: - Media Keys Events
    
    private func mediaKeyEvent(key: Int32, down: Bool) {
        guard down else { return }
        
        switch(key) {
        case NX_KEYTYPE_PLAY: playPressed()
        case NX_KEYTYPE_FAST: forwardPressed()
        case NX_KEYTYPE_REWIND: backwardPressed()
        default: break
        }
    }
    
    // MARK: Event tap
    
    private var eventTap: PMEventTap!
    
    private func startEventTap() {
        eventTap = PMEventTap(mediaKeyEventHandler: mediaKeyEvent)
        eventTap.start()
    }
    
}
