//
//  VUController.swift
//  PodcastMenu
//
//  Created by Guilherme Rambo on 11/05/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa

class VUController: OvercastLoudnessDelegate {
    
    var statusItem: NSStatusItem
    var timeoutTimer: NSTimer!
    
    init(statusItem: NSStatusItem) {
        self.statusItem = statusItem
    }
    
    private var hadVUEnabled = false
    
    func loudnessDidChange(value: Double) {
        guard Preferences.enableVU else {
            if (hadVUEnabled) {
                timeoutTimerAction()
                hadVUEnabled = false
            }
            
            return
        }
        
        hadVUEnabled = true
        
        resetTimeoutTimer()
        
        statusItem.image = imageForLoudness(value)
    }
    
    private lazy var baseImage = NSImage(named: "podcast")!
    private lazy var baseImageCG = NSImage(named: "podcast")!.CGImage
    private let startAngle = CGFloat(M_PI / 2.0 * -1.0)
    private let endAngle = CGFloat(2.0 * M_PI) + CGFloat(M_PI / 2.0 * -1.0)
    
    private func imageForLoudness(value: Double) -> NSImage {
        let image = NSImage(size: statusItem.image!.size)
        let w = image.size.width
        let h = image.size.height
        
        image.lockFocus()
        
        let ctx = NSGraphicsContext.currentContext()!.CGContext
        
        let maskBounds = CGRect(x: 0.0, y: 0.0, width: w, height: h)
        CGContextClipToMask(ctx, maskBounds, baseImageCG)

        if !statusItem.button!.highlighted {
            CGContextSetFillColorWithColor(ctx, Theme.Colors.iconFill.colorWithAlphaComponent(0.1).CGColor)
            CGContextFillRect(ctx, maskBounds)
        }
        
        let relativeLoudness = value / Constants.maxLoudness
        let radius = max(w * CGFloat(relativeLoudness), h * CGFloat(relativeLoudness)) * CGFloat(0.9)
        
        CGContextSetFillColorWithColor(ctx, Theme.Colors.tint.CGColor)
        CGContextAddArc(ctx, w / 2.0, h / 2.0 - 1.0, radius, startAngle, endAngle, 0)
        CGContextFillPath(ctx)
        
        image.unlockFocus()
        
        return image
    }
    
    private func resetTimeoutTimer() {
        if (timeoutTimer != nil) {
            timeoutTimer.invalidate()
            timeoutTimer = nil
        }
        
        timeoutTimer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: #selector(timeoutTimerAction), userInfo: nil, repeats: false)
    }
    
    @objc private func timeoutTimerAction() {
        statusItem.image = baseImage
    }
    
}