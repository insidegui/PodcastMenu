//
//  Theme.swift
//  PodcastMenu
//
//  Created by Guilherme Rambo on 10/05/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa

extension Notification.Name {
    static let SystemAppearanceDidChange = Notification.Name(rawValue: "SystemAppearanceDidChange")
}

class Theme: NSObject {
    
    struct Colors {
        static var tint: NSColor {
            return Theme.isDark ? NSColor(calibratedRed:0.29, green:0.71, blue:0.75, alpha:1.00) : NSColor(calibratedRed:0.989, green:0.496, blue:0.059, alpha:1)
        }
        
        static var background: NSColor {
            return Theme.isDark ? NSColor(calibratedRed:0.19, green:0.20, blue:0.20, alpha:1.00) : .white
        }
        
        static var iconFill: NSColor {
            return Theme.isDark ? NSColor.white : NSColor.black
        }
    }
    
    static var isDark: Bool {
        return UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark"
    }
    
    static var appearance: NSAppearance? {
        return isDark ? NSAppearance(named: NSAppearanceNameVibrantDark) : NSAppearance(named: NSAppearanceNameAqua)
    }
    
    override init() {
        super.init()
        
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(systemAppearanceChanged), name: NSNotification.Name(rawValue: "AppleInterfaceThemeChangedNotification"), object: nil)
    }
    
    @objc fileprivate func systemAppearanceChanged() {
        NotificationCenter.default.post(name: .SystemAppearanceDidChange, object: nil)
    }
    
}
