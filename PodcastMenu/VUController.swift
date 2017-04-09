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
    var timeoutTimer: Timer!
    
    init(statusItem: NSStatusItem) {
        self.statusItem = statusItem
        
        NotificationCenter.default.addObserver(forName: Notification.Name.OvercastDidPause, object: nil, queue: nil) { [weak self] _ in
            self?.resetToDefaultImage()
        }
    }
    
    func loudnessDidChange(_ value: Double) {
        guard Preferences.enableVU else { return resetToDefaultImage() }
        
        statusItem.image = imageForLoudness(value)
    }
    
    fileprivate lazy var baseImage = NSImage(named: "podcast")!
    fileprivate lazy var baseImageCG: CGImage = NSImage(named: "podcast")!.cgImage
    fileprivate let startAngle = CGFloat(Double.pi / 2.0 * -1.0)
    fileprivate let endAngle = CGFloat(2.0 * Double.pi) + CGFloat(Double.pi / 2.0 * -1.0)
    
    fileprivate func imageForLoudness(_ value: Double) -> NSImage {
        let image = NSImage(size: statusItem.image!.size)
        let w = image.size.width
        let h = image.size.height
        
        image.lockFocus()
        
        let ctx = NSGraphicsContext.current()!.cgContext
        
        let maskBounds = CGRect(x: 0.0, y: 0.0, width: w, height: h)
        ctx.clip(to: maskBounds, mask: baseImageCG)

        if !statusItem.button!.isHighlighted {
            ctx.setFillColor(Theme.Colors.iconFill.withAlphaComponent(0.1).cgColor)
            ctx.fill(maskBounds)
        }
        
        let relativeLoudness = value / Constants.maxLoudness
        let radius = max(w * CGFloat(relativeLoudness), h * CGFloat(relativeLoudness)) * CGFloat(0.9)
        
        ctx.setFillColor(Theme.Colors.tint.cgColor)
        ctx.addArc(center: CGPoint(x: w / 2.0, y: h / 2.0), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        ctx.fillPath()
        
        image.unlockFocus()
        
        return image
    }
    
    fileprivate func resetToDefaultImage() {
        statusItem.image = baseImage
    }
    
}
