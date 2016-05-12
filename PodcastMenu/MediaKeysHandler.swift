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
        
        // disables the system's default media keys handler (stops rcd service)
        setDefaultSystemMediaKeysHandlingEnabled(false)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reenableSystemMediaKeys), name: NSApplicationWillTerminateNotification, object: nil)
        
        PodcastMenuApplication.Notifications.DidPressPlay.subscribe(playPressed)
        PodcastMenuApplication.Notifications.DidPressForward.subscribe(forwardPressed)
        PodcastMenuApplication.Notifications.DidPressBackward.subscribe(backwardPressed)
    }
    
    private func setDefaultSystemMediaKeysHandlingEnabled(enabled: Bool) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            let task = NSTask()
            task.launchPath = "/bin/launchctl"
            let command = enabled ? "load" : "unload"
            task.arguments = [command, "/System/Library/LaunchAgents/com.apple.rcd.plist"]
            task.launch()
            task.waitUntilExit()
        }
    }
    
    @objc private func reenableSystemMediaKeys() {
        setDefaultSystemMediaKeysHandlingEnabled(true)
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
    
}
