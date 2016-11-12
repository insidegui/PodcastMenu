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

    fileprivate var updater = SUUpdater()
    
    fileprivate var statusItem: NSStatusItem!
    fileprivate lazy var popoverController = StatusPopoverController()
    fileprivate var vuController: VUController!

    func applicationWillFinishLaunching(_ notification: Notification) {
        UserDefaults.standard.register(defaults: ["NSApplicationCrashOnExceptions": true])
        
        registerURLHandler()
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Fabric.with([Crashlytics.self])
        
        statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
        statusItem.image = NSImage(named: "podcast")!
        statusItem.target = self
        statusItem.action = #selector(statusItemAction(_:))
        statusItem.highlightMode = true
        
        vuController = VUController(statusItem: statusItem)
        popoverController.webAppController.loudnessDelegate = vuController
        
        perform(#selector(statusItemAction(_:)), with: statusItem.button, afterDelay: 0.5)
    }
    
    @objc fileprivate func statusItemAction(_ sender: NSStatusBarButton) {
        popoverController.showPopoverFromStatusItemButton(sender)
    }
    
    fileprivate func registerURLHandler() {
        NSAppleEventManager.shared().setEventHandler(self, andSelector: #selector(handleURLEvent(_:replyEvent:)), forEventClass: UInt32(kInternetEventClass), andEventID: UInt32(kAEGetURL))
    }
    
    @objc fileprivate func handleURLEvent(_ event: NSAppleEventDescriptor!, replyEvent: NSAppleEventDescriptor!) {
        guard let urlString = event.paramDescriptor(forKeyword: UInt32(keyDirectObject))?.stringValue else { return }
        guard let URL = URL(string: urlString) else { return }
        guard statusItem?.button != nil else { return }
        
        statusItemAction(statusItem.button!)
        
        popoverController.webAppController.openURL(URL)
    }

}
