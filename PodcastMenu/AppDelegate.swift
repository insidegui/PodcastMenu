//
//  AppDelegate.swift
//  PodcastMenu
//
//  Created by Guilherme Rambo on 10/05/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa

import Sparkle
import Fabric
import Crashlytics

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    private var updater = SUUpdater()
    
    private var statusItem: NSStatusItem!
    private lazy var popoverController = StatusPopoverController()

    func applicationWillFinishLaunching(notification: NSNotification) {
        NSUserDefaults.standardUserDefaults().registerDefaults(["NSApplicationCrashOnExceptions": true])
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        Fabric.with([Crashlytics.self])
        
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
        statusItem.image = NSImage(named: "podcast")!
        statusItem.target = self
        statusItem.action = #selector(statusItemAction(_:))
        statusItem.highlightMode = true
        
        performSelector(#selector(statusItemAction(_:)), withObject: statusItem.button, afterDelay: 0.5)
    }
    
    @objc private func statusItemAction(sender: NSStatusBarButton) {
        popoverController.showPopoverFromStatusItemButton(sender)
    }

}

