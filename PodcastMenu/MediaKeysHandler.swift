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
    
    @objc fileprivate func playPressed() {
        DispatchQueue.main.async(execute: playPauseHandler)
    }
    
    @objc fileprivate func forwardPressed() {
        DispatchQueue.main.async(execute: forwardHandler)
    }
    
    @objc fileprivate func backwardPressed() {
        DispatchQueue.main.async(execute: backwardHandler)
    }
    
    // MARK: - Media Keys Events
    
    fileprivate func mediaKeyEvent(_ key: Int32, down: Bool) {
        guard down else { return }
        
        switch(key) {
        case NX_KEYTYPE_PLAY: playPressed()
        case NX_KEYTYPE_FAST: forwardPressed()
        case NX_KEYTYPE_REWIND: backwardPressed()
        default: break
        }
    }
    
    // MARK: Event tap
    
    fileprivate var eventTap: PMEventTap!
    
    fileprivate func startEventTap() {
        eventTap = PMEventTap(mediaKeyEventHandler: mediaKeyEvent)
        eventTap.start()
    }
    
}
