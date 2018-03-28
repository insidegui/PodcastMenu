//
//  Preferences.swift
//  PodcastMenu
//
//  Created by Guilherme Rambo on 11/05/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation

class Preferences {
    
    fileprivate class var defaults: UserDefaults {
        return UserDefaults.standard
    }
    
    class var enableVU: Bool {
        set {
            #if DEBUG
            NSLog("enableVU = \(!newValue)")
            #endif
            defaults.set(!newValue, forKey: "vudisabled")
            defaults.synchronize()
        }
        get {
            return !defaults.bool(forKey: "vudisabled")
        }
    }
    
    class var mediaKeysPassthroughEnabled: Bool {
        set {
            defaults.set(newValue, forKey: "mediakeyspassthrough")
            defaults.synchronize()
        }
        get {
            return defaults.bool(forKey: "mediakeyspassthrough")
        }
    }
    
    class var notificationsEnabled: Bool {
        set {
            defaults.set(newValue, forKey: "enableNotifications")
            defaults.synchronize()
        }
        get {
        
            return defaults.bool(forKey: "enableNotifications")
        }
    }
    
}
