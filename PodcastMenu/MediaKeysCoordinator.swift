//
//  MediaKeysCoordinator.swift
//  PodcastMenu
//
//  Created by Guilherme Rambo on 15/05/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation

class MediaKeysCoordinator: NSObject {
    
    private let mediaKeysUsers: [String]
    
    override init() {
        let data = NSData(contentsOfURL: NSBundle.mainBundle().URLForResource("MediaKeysUsers", withExtension: "plist")!)!
        self.mediaKeysUsers = try! NSPropertyListSerialization.propertyListWithData(data, options: .Immutable, format: nil) as! [String]
        
        super.init()
        
        
        NSWorkspace.sharedWorkspace().addObserver(self, forKeyPath: "frontmostApplication", options: [.Initial, .New], context: nil)
        NSWorkspace.sharedWorkspace().addObserver(self, forKeyPath: "runningApplications", options: [.Initial, .New], context: nil)
    }
    
    private var keysOwnedByAnotherApplication = false
    
    func shouldInterceptMediaKeys() -> Bool {
        return keysOwnedByAnotherApplication == false || Preferences.mediaKeysPassthroughEnabled
    }
    
    func shouldPassthroughMediaKeysEvents() -> Bool {
        return Preferences.mediaKeysPassthroughEnabled
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "frontmostApplication" {
            // if frontmost application is one of the apps listed in mediaKeysUsers, disable media keys handling, if It's our app, reenable if disabled
            if let identifier = NSWorkspace.sharedWorkspace().frontmostApplication?.bundleIdentifier {
                if !keysOwnedByAnotherApplication {
                    if (mediaKeysUsers.contains(identifier)) {
                        keysOwnedByAnotherApplication = true
                        #if DEBUG
                        NSLog("[MediaKeysCoordinator] Media keys now owned by \(identifier)")
                        #endif
                    }
                } else {
                    if identifier == NSBundle.mainBundle().bundleIdentifier {
                        keysOwnedByAnotherApplication = false
                        #if DEBUG
                        NSLog("[MediaKeysCoordinator] Media keys now owned by PodcastMenu")
                        #endif
                    }
                }
            }
        } else if keyPath == "runningApplications" {
            if !NSWorkspace.sharedWorkspace().runningApplications.reduce(false, combine: { $0 ? $0 : mediaKeysUsers.contains($1.bundleIdentifier ?? "") }) {
                // all media keys users have quit, reclaim media keys
                keysOwnedByAnotherApplication = false
                #if DEBUG
                NSLog("[MediaKeysCoordinator] Media keys now owned by PodcastMenu because no other media apps are running")
                #endif
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
}