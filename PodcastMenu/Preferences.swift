//
//  Preferences.swift
//  PodcastMenu
//
//  Created by Guilherme Rambo on 11/05/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation

class Preferences {
    
    private class var defaults: NSUserDefaults {
        return NSUserDefaults.standardUserDefaults()
    }
    
    class var enableVU: Bool {
        set {
            #if DEBUG
            NSLog("enableVU = \(!newValue)")
            #endif
            defaults.setBool(!newValue, forKey: "vudisabled")
            defaults.synchronize()
        }
        get {
            return !defaults.boolForKey("vudisabled")
        }
    }
    
    class var mediaKeysPassthroughEnabled: Bool {
        set {
            defaults.setBool(newValue, forKey: "mediakeyspassthrough")
            defaults.synchronize()
        }
        get {
            return defaults.boolForKey("mediakeyspassthrough")
        }
    }
    
}