//
//  StatusPopoverController.swift
//  PodcastMenu
//
//  Created by Guilherme Rambo on 10/05/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa

class StatusPopoverController: NSObject {

    private var theme = Theme()
    private var popover: NSPopover?
    private lazy var webAppController = PodcastWebAppViewController()
    private var themeObserver: NSObjectProtocol?
    
    override init() {
        super.init()
        
        themeObserver = Theme.Notifications.SystemAppearanceDidChange.subscribe { [unowned self] _ in
            self.updatePopoverAppearance()
        }
        
        installApplicationTerminationListener()
    }
    
    func showPopoverFromStatusItemButton(statusItemButton: NSStatusBarButton) {
        if popover == nil {
            popover = NSPopover()
            popover!.contentViewController = webAppController
            popover!.behavior = .Transient
        }
        
        updatePopoverAppearance()
        
        popover!.showRelativeToRect(NSZeroRect, ofView: statusItemButton, preferredEdge: .MaxY)
        
        NSApp.activateIgnoringOtherApps(true)
    }
    
    private func installApplicationTerminationListener() {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StatusPopoverController.closePopover), name: NSApplicationDidResignActiveNotification, object: nil)
        }
    }
    
    private func updatePopoverAppearance() {
        guard let popover = popover else { return }
        
        popover.appearance = Theme.isDark ? NSAppearance(named: NSAppearanceNameVibrantDark) : nil
    }
    
    @objc private func closePopover() {
        guard let popover = popover else { return }
        
        popover.performClose(nil)
    }
    
    deinit {
        if let themeObserver = themeObserver {
            Theme.Notifications.SystemAppearanceDidChange.unsubscribe(themeObserver)
        }
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
