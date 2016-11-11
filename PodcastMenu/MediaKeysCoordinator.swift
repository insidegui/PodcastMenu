//
//  MediaKeysCoordinator.swift
//  PodcastMenu
//
//  Created by Guilherme Rambo on 15/05/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation

class MediaKeysCoordinator: NSObject {
    
    fileprivate let mediaKeysUsers: [String]
    
    override init() {
        let data = try! Data(contentsOf: Bundle.main.url(forResource: "MediaKeysUsers", withExtension: "plist")!)
        self.mediaKeysUsers = try! PropertyListSerialization.propertyList(from: data, options: PropertyListSerialization.MutabilityOptions(), format: nil) as! [String]
        
        super.init()
        
        
        NSWorkspace.shared().addObserver(self, forKeyPath: "frontmostApplication", options: [.initial, .new], context: nil)
        NSWorkspace.shared().addObserver(self, forKeyPath: "runningApplications", options: [.initial, .new], context: nil)
    }
    
    fileprivate var keysOwnedByAnotherApplication = false
    
    func shouldInterceptMediaKeys() -> Bool {
        return keysOwnedByAnotherApplication == false || Preferences.mediaKeysPassthroughEnabled
    }
    
    func shouldPassthroughMediaKeysEvents() -> Bool {
        return Preferences.mediaKeysPassthroughEnabled
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "frontmostApplication" {
            // if frontmost application is one of the apps listed in mediaKeysUsers, disable media keys handling, if It's our app, reenable if disabled
            if let identifier = NSWorkspace.shared().frontmostApplication?.bundleIdentifier {
                if !keysOwnedByAnotherApplication {
                    if (mediaKeysUsers.contains(identifier)) {
                        keysOwnedByAnotherApplication = true
                        #if DEBUG
                        NSLog("[MediaKeysCoordinator] Media keys now owned by \(identifier)")
                        #endif
                    }
                } else {
                    if identifier == Bundle.main.bundleIdentifier {
                        keysOwnedByAnotherApplication = false
                        #if DEBUG
                        NSLog("[MediaKeysCoordinator] Media keys now owned by PodcastMenu")
                        #endif
                    }
                }
            }
        } else if keyPath == "runningApplications" {
            if !NSWorkspace.shared().runningApplications.reduce(false, { $0 ? $0 : mediaKeysUsers.contains($1.bundleIdentifier ?? "") }) {
                // all media keys users have quit, reclaim media keys
                keysOwnedByAnotherApplication = false
                #if DEBUG
                NSLog("[MediaKeysCoordinator] Media keys now owned by PodcastMenu because no other media apps are running")
                #endif
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
}
