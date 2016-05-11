//
//  Theme.swift
//  PodcastMenu
//
//  Created by Guilherme Rambo on 10/05/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa

class Theme: NSObject {
    
    enum Notifications: String {
        case SystemAppearanceDidChange
        
        private func post() {
            NSNotificationCenter.defaultCenter().postNotificationName(self.rawValue, object: nil)
        }
        
        func subscribe(block: (notification: NSNotification) -> ()) -> NSObjectProtocol {
            return NSNotificationCenter.defaultCenter().addObserverForName(self.rawValue, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: block)
        }
        
        func unsubscribe(observer: NSObjectProtocol) {
            NSNotificationCenter.defaultCenter().removeObserver(observer, name: self.rawValue, object: nil)
        }
    }
    
    struct Colors {
        static let tint = NSColor(calibratedRed:0.989, green:0.496, blue:0.059, alpha:1)
        
        static var iconFill: NSColor {
            return Theme.isDark ? NSColor.whiteColor() : NSColor.blackColor()
        }
    }
    
    static var isDark: Bool {
        return NSUserDefaults.standardUserDefaults().stringForKey("AppleInterfaceStyle") == "Dark"
    }
    
    override init() {
        super.init()
        
        NSDistributedNotificationCenter.defaultCenter().addObserver(self, selector: #selector(systemAppearanceChanged), name: "AppleInterfaceThemeChangedNotification", object: nil)
    }
    
    @objc private func systemAppearanceChanged() {
        Notifications.SystemAppearanceDidChange.post()
    }
    
}