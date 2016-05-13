//
//  PodcastWebAppViewController.swift
//  PodcastMenu
//
//  Created by Guilherme Rambo on 10/05/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa
import WebKit
import Sparkle

class PodcastWebAppViewController: NSViewController {
    
    var loudnessDelegate: OvercastLoudnessDelegate?
    
    init() {
        super.init(nibName: nil, bundle: nil)!
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private lazy var progressBar = ProgressBar(frame: NSZeroRect)
    private lazy var webView: PMWebView = PMWebView(frame: NSZeroRect)
    private var overcastController: OvercastController!
    
    private lazy var configMenuButton: NSButton = {
        let b = NSButton(frame: NSZeroRect)
        
        b.translatesAutoresizingMaskIntoConstraints = false
        b.bordered = false
        b.bezelStyle = NSBezelStyle.RegularSquareBezelStyle
        b.setButtonType(.MomentaryLightButton)
        b.image = NSImage(named: NSImageNameActionTemplate)
        b.toolTip = NSLocalizedString("Options", comment: "Options menu tooltip")
        b.sizeToFit()
        
        return b
    }()
    
    override func loadView() {
        view = NSView(frame: NSRect(x: 0.0, y: 0.0, width: Metrics.viewportWidth, height: Metrics.viewportHeight))
        view.wantsLayer = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        webView.topAnchor.constraintEqualToAnchor(view.topAnchor, constant: Metrics.webViewMargin).active = true
        webView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: -Metrics.webViewMargin).active = true
        webView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor, constant: Metrics.webViewMargin).active = true
        webView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor, constant: -Metrics.webViewMargin).active = true
        
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.tintColor = Theme.Colors.tint
        progressBar.completedThreshold = 0.80
        
        view.addSubview(progressBar)
        progressBar.addConstraint(NSLayoutConstraint(item: progressBar, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: Metrics.progressBarThickness))
        progressBar.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
        progressBar.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
        progressBar.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
        
        createConfigMenu()
        
        configMenuButton.target = self
        configMenuButton.action = #selector(showConfigMenu)
        configMenuButton.sendActionOn(Int(NSEventMask.LeftMouseDownMask.rawValue))
        
        view.addSubview(configMenuButton)
        
        configMenuButton.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor, constant: -10.0).active = true
        configMenuButton.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: -10.0).active = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overcastController = OvercastController(webView: webView)
        overcastController.loudnessDelegate = loudnessDelegate
        
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: [.Initial, .New], context: nil)
        
        webView.loadRequest(NSURLRequest(URL: Constants.webAppURL))
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard keyPath == "estimatedProgress" else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return
        }
        
        progressBar.progress = webView.estimatedProgress
    }
    
    func openURL(URL: NSURL) {
        guard overcastController.isValidOvercastURL(URL) else {
            NSWorkspace.sharedWorkspace().openURL(URL)
            return
        }
        
        webView.loadRequest(NSURLRequest(URL: URL))
    }
    
    // MARK: - Configuration Menu
    
    private lazy var configMenu = NSMenu()
    
    private func createConfigMenu() {
        let vuItem = NSMenuItem(title: NSLocalizedString("Enable VU Meter", comment: "Enable VU Meter"), action: #selector(toggleReflectAudioLevelInIcon(_:)), keyEquivalent: "")
        vuItem.target = self
        vuItem.state = Preferences.enableVU ? NSOnState : NSOffState
        
        let updateItem = NSMenuItem(title: NSLocalizedString("Check for Updates…", comment: "Check for Updates"), action: #selector(checkForUpdates(_:)), keyEquivalent: "")
        updateItem.target = self
        
        let quitItem = NSMenuItem(title: NSLocalizedString("Quit", comment: "Quit"), action: #selector(NSApplication.terminate(_:)), keyEquivalent: "")
        quitItem.target = NSApp
        
        configMenu.addItem(vuItem)
        configMenu.addItem(NSMenuItem.separatorItem())
        configMenu.addItem(updateItem)
        configMenu.addItem(quitItem)
    }
    
    @objc private func showConfigMenu() {
        configMenu.popUpMenuPositioningItem(nil, atLocation: NSZeroPoint, inView: configMenuButton)
    }
    
    @objc private func toggleReflectAudioLevelInIcon(sender: NSMenuItem) {
        sender.state = sender.state == NSOnState ? NSOffState : NSOnState
        Preferences.enableVU = (sender.state == NSOnState)
    }
    
    @objc private func checkForUpdates(sender: NSMenuItem) {
        SUUpdater.sharedUpdater().checkForUpdates(sender)
    }
    
}
