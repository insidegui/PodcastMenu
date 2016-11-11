//
//  StatusPopoverController.swift
//  PodcastMenu
//
//  Created by Guilherme Rambo on 10/05/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa

class StatusPopoverController: NSObject {

    fileprivate var theme = Theme()
    fileprivate var popover: NSPopover?
    lazy var webAppController = PodcastWebAppViewController()
    fileprivate var themeObserver: NSObjectProtocol?
    
    override init() {
        super.init()
        
        themeObserver = NotificationCenter.default.addObserver(forName: Notification.Name.SystemAppearanceDidChange, object: nil, queue: nil) { [weak self] _ in
            self?.updatePopoverAppearance()
        }
        
        installApplicationTerminationListener()
    }
    
    func showPopoverFromStatusItemButton(_ statusItemButton: NSStatusBarButton) {
        if popover == nil {
            popover = NSPopover()
            popover!.contentViewController = webAppController
            popover!.behavior = .transient
        }
        
        updatePopoverAppearance()
        
        popover!.show(relativeTo: NSZeroRect, of: statusItemButton, preferredEdge: .maxY)
        
        NSApp.activate(ignoringOtherApps: true)
    }
    
    fileprivate func installApplicationTerminationListener() {
        let delayTime = DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            NotificationCenter.default.addObserver(self, selector: #selector(StatusPopoverController.closePopover), name: NSNotification.Name.NSApplicationDidResignActive, object: nil)
        }
    }
    
    fileprivate func updatePopoverAppearance() {
        guard let popover = popover else { return }
        
        popover.appearance = Theme.isDark ? NSAppearance(named: NSAppearanceNameVibrantDark) : nil
    }
    
    @objc fileprivate func closePopover() {
        guard let popover = popover else { return }
        
        popover.performClose(nil)
    }
    
    deinit {
        if let themeObserver = themeObserver {
            NotificationCenter.default.removeObserver(themeObserver)
        }
        
        NotificationCenter.default.removeObserver(self)
    }
    
}
