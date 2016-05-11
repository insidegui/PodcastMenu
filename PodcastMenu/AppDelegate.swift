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
        
        registerURLHandler()
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
    
    private func registerURLHandler() {
        NSAppleEventManager.sharedAppleEventManager().setEventHandler(self, andSelector: #selector(handleURLEvent(_:replyEvent:)), forEventClass: UInt32(kInternetEventClass), andEventID: UInt32(kAEGetURL))
    }
    
    @objc private func handleURLEvent(event: NSAppleEventDescriptor!, replyEvent: NSAppleEventDescriptor!) {
        guard let urlString = event.paramDescriptorForKeyword(UInt32(keyDirectObject))?.stringValue else { return }
        guard let URL = NSURL(string: urlString) else { return }
        guard statusItem?.button != nil else { return }
        
        statusItemAction(statusItem.button!)
        
        popoverController.webAppController.openURL(URL)
    }

}

