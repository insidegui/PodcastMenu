//
//  Preferences.swift
//  PodcastMenu
//
//  Created by Guilherme Rambo on 11/05/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation

class Preferences {
    
    class var enableVU: Bool {
        set {
            NSLog("enableVU = \(!newValue)")
            NSUserDefaults.standardUserDefaults().setBool(!newValue, forKey: "vudisabled")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        get {
            return !NSUserDefaults.standardUserDefaults().boolForKey("vudisabled")
        }
    }
    
}