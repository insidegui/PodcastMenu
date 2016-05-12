//
//  PodcastMenuApplication.swift
//  PodcastMenu
//
//  Created by Guilherme Rambo on 10/05/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa

class PodcastMenuApplication: NSApplication {
    
    enum Notifications: String, NotificationsBase {
        case DidPressPlay
        case DidPressForward
        case DidPressBackward
    }
    
    // source: http://sernprogramming.com/blog/handling-media-key-events-in-swift/
    override func sendEvent(event: NSEvent) {
        if (event.type == .SystemDefined && event.subtype.rawValue == 8) {
            let keyCode = ((event.data1 & 0xFFFF0000) >> 16)
            let keyFlags = (event.data1 & 0x0000FFFF)
            
            // Get the key state. 0xA is KeyDown, OxB is KeyUp
            let keyState = (((keyFlags & 0xFF00) >> 8)) == 0xA
            let keyRepeat = (keyFlags & 0x1)
            
            mediaKeyEvent(Int32(keyCode), state: keyState, keyRepeat: Bool(keyRepeat))
        }
        
        super.sendEvent(event)
    }
    
    private func mediaKeyEvent(key: Int32, state: Bool, keyRepeat: Bool) {
        guard state else { return }
        
        switch(key) {
        case NX_KEYTYPE_PLAY: Notifications.DidPressPlay.post()
        case NX_KEYTYPE_FAST: Notifications.DidPressForward.post()
        case NX_KEYTYPE_REWIND: Notifications.DidPressBackward.post()
        default: break
        }
    }
    
}
