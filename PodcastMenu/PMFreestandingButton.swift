//
//  PMFreestandingButton.swift
//  PodcastMenu
//
//  Created by Guilherme Rambo on 09/04/17.
//  Copyright © 2017 Guilherme Rambo. All rights reserved.
//

import Cocoa

class PMFreestandingButton: NSButton {

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        wantsLayer = true
    }
    
    override var isOpaque: Bool {
        return false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var allowsVibrancy: Bool {
        return false
    }
    
    override class func cellClass() -> AnyClass {
        return PMFreestandingButtonCell.self
    }
    
    override var isHighlighted: Bool {
        didSet {
            setNeedsDisplay()
        }
    }
    
}

final class PMFreestandingButtonCell: NSButtonCell {
    
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        guard let image = image else { return }
        
        guard let ctx = NSGraphicsContext.current()?.cgContext else { return }
        ctx.saveGState()
        
        let constrainedWidth: CGFloat
        let constrainedHeight: CGFloat
        
        let rw = image.size.width / cellFrame.width
        let rh = image.size.height / cellFrame.height
        
        if (rw > rh) {
            constrainedHeight = round(image.size.height / rw)
            constrainedWidth = cellFrame.width
        } else {
            constrainedWidth = round(image.size.width / rh)
            constrainedHeight = cellFrame.height
        }
        
        let maskRect = NSRect(
            x: (cellFrame.width / 2.0 - constrainedWidth / 2.0),
            y: (cellFrame.height / 2.0 - constrainedHeight / 2.0),
            width: constrainedWidth,
            height: constrainedHeight
        )
        
        ctx.translateBy(x: 0, y: constrainedHeight)
        ctx.scaleBy(x: 1, y: -1)
        
        ctx.clip(to: maskRect, mask: image.cgImageForCurrentScale)
        ctx.setFillColor(Theme.Colors.tint.cgColor)
        ctx.fill(cellFrame)
        
        ctx.restoreGState()
    }
    
}
