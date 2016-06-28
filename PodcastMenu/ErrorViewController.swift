//
//  ErrorViewController.swift
//  PodcastMenu
//
//  Created by Guilherme Rambo on 28/06/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa

class ErrorViewController: NSViewController {

    private let error: NSError
    
    var reloadHandler = {}
    
    init(error: NSError) {
        self.error = error
        
        super.init(nibName: nil, bundle: nil)!
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let errorLabel: NSTextField = {
        let f = NSTextField(frame: NSZeroRect)
        
        f.editable = false
        f.bezeled = false
        f.bordered = false
        f.selectable = false
        f.backgroundColor = Theme.Colors.tint
        f.textColor = NSColor(calibratedWhite: 0, alpha: 0.7)
        f.translatesAutoresizingMaskIntoConstraints = false
        
        return f
    }()
    
    private let reloadButton: NSButton = {
        let b = NSButton(frame: NSZeroRect)
        
        b.image = NSImage(named: NSImageNameRefreshFreestandingTemplate)
        b.setButtonType(.MomentaryPushInButton)
        b.bordered = false
        b.bezelStyle = NSBezelStyle.ShadowlessSquareBezelStyle
        b.sizeToFit()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.appearance = NSAppearance(named: NSAppearanceNameAqua)
        
        return b
    }()
    
    override func loadView() {
        view = NSView(frame: NSZeroRect)
        view.wantsLayer = true
        view.layer?.backgroundColor = Theme.Colors.tint.CGColor
        
        view.addSubview(errorLabel)
        errorLabel.setContentCompressionResistancePriority(NSLayoutPriorityDefaultLow, forOrientation: .Horizontal)
        errorLabel.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor).active = true
        errorLabel.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor, constant: Metrics.errorBarMargin).active = true
        
        view.addSubview(reloadButton)
        reloadButton.leadingAnchor.constraintEqualToAnchor(errorLabel.trailingAnchor, constant: 8.0).active = true
        reloadButton.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor, constant: -Metrics.errorBarMargin).active = true
        reloadButton.centerYAnchor.constraintEqualToAnchor(errorLabel.centerYAnchor).active = true
        
        reloadButton.target = self
        reloadButton.action = #selector(reload)
    }
    
    @objc private func reload() {
        reloadHandler()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorLabel.stringValue = error.localizedDescription
    }
    
}
