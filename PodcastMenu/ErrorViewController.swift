//
//  ErrorViewController.swift
//  PodcastMenu
//
//  Created by Guilherme Rambo on 28/06/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa

class ErrorViewController: NSViewController {

    fileprivate let error: NSError
    
    var reloadHandler = {}
    
    init(error: NSError) {
        self.error = error
        
        super.init(nibName: nil, bundle: nil)!
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate let errorLabel: NSTextField = {
        let f = NSTextField(frame: NSZeroRect)
        
        f.isEditable = false
        f.isBezeled = false
        f.isBordered = false
        f.isSelectable = false
        f.backgroundColor = Theme.Colors.tint
        f.textColor = NSColor(calibratedWhite: 0, alpha: 0.7)
        f.translatesAutoresizingMaskIntoConstraints = false
        
        return f
    }()
    
    fileprivate let reloadButton: NSButton = {
        let b = NSButton(frame: NSZeroRect)
        
        b.image = NSImage(named: NSImageNameRefreshFreestandingTemplate)
        b.setButtonType(.momentaryPushIn)
        b.isBordered = false
        b.bezelStyle = NSBezelStyle.shadowlessSquare
        b.sizeToFit()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.appearance = NSAppearance(named: NSAppearanceNameAqua)
        
        return b
    }()
    
    override func loadView() {
        view = NSView(frame: NSZeroRect)
        view.wantsLayer = true
        view.layer?.backgroundColor = Theme.Colors.tint.cgColor
        
        view.addSubview(errorLabel)
        errorLabel.setContentCompressionResistancePriority(NSLayoutPriorityDefaultLow, for: .horizontal)
        errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Metrics.errorBarMargin).isActive = true
        
        view.addSubview(reloadButton)
        reloadButton.leadingAnchor.constraint(equalTo: errorLabel.trailingAnchor, constant: 8.0).isActive = true
        reloadButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Metrics.errorBarMargin).isActive = true
        reloadButton.centerYAnchor.constraint(equalTo: errorLabel.centerYAnchor).isActive = true
        
        reloadButton.target = self
        reloadButton.action = #selector(reload)
    }
    
    @objc fileprivate func reload() {
        reloadHandler()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorLabel.stringValue = error.localizedDescription
    }
    
}
