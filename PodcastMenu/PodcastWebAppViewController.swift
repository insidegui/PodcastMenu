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
    
    fileprivate lazy var progressBar = ProgressBar(frame: NSZeroRect)
    fileprivate lazy var webView: PMWebView = PMWebView(frame: NSZeroRect)
    fileprivate var overcastController: OvercastController!
    
    fileprivate lazy var configMenuButton: NSButton = {
        let b = NSButton(frame: NSZeroRect)
        
        b.translatesAutoresizingMaskIntoConstraints = false
        b.isBordered = false
        b.bezelStyle = .shadowlessSquare
        b.setButtonType(.momentaryPushIn)
        b.image = NSImage(named: NSImageNameActionTemplate)
        b.toolTip = NSLocalizedString("Options", comment: "Options menu tooltip")
        b.sizeToFit()
        b.appearance = NSAppearance(named: NSAppearanceNameAqua)
        
        return b
    }()
    
    override func loadView() {
        view = NSView(frame: NSRect(x: 0.0, y: 0.0, width: Metrics.viewportWidth, height: Metrics.viewportHeight))
        view.wantsLayer = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        webView.topAnchor.constraint(equalTo: view.topAnchor, constant: Metrics.webViewMargin).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Metrics.webViewMargin).isActive = true
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Metrics.webViewMargin).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Metrics.webViewMargin).isActive = true
        
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.tintColor = Theme.Colors.tint
        progressBar.completedThreshold = 0.80
        
        view.addSubview(progressBar)
        progressBar.addConstraint(NSLayoutConstraint(item: progressBar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: Metrics.progressBarThickness))
        progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        progressBar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        progressBar.layer?.zPosition = 100
        
        createConfigMenu()
        
        configMenuButton.target = self
        configMenuButton.action = #selector(showConfigMenu)
        configMenuButton.sendAction(on: NSEventMask(rawValue: UInt64(Int(NSEventMask.leftMouseDown.rawValue))))
        
        view.addSubview(configMenuButton)
        
        configMenuButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10.0).isActive = true
        configMenuButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10.0).isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overcastController = OvercastController(webView: webView)
        overcastController.loudnessDelegate = loudnessDelegate
        
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: [.initial, .new], context: nil)
        
        webView.load(URLRequest(url: Constants.webAppURL as URL))
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        view.window?.alphaValue = 1.0
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == "estimatedProgress" else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        progressBar.progress = webView.estimatedProgress
    }
    
    func openURL(_ URL: Foundation.URL) {
        guard overcastController.isValidOvercastURL(URL) else {
            NSWorkspace.shared().open(URL)
            return
        }
        
        webView.load(URLRequest(url: URL))
    }
    
    // MARK: - Configuration Menu
    
    fileprivate lazy var configMenu = NSMenu()
    
    fileprivate func createConfigMenu() {
        let reloadItem = NSMenuItem(title: NSLocalizedString("Reload", comment: "Reload"), action: #selector(reload(_:)), keyEquivalent: "")
        reloadItem.target = self
        
        let vuItem = NSMenuItem(title: NSLocalizedString("Enable VU Meter", comment: "Enable VU Meter"), action: #selector(toggleReflectAudioLevelInIcon(_:)), keyEquivalent: "")
        vuItem.target = self
        vuItem.state = Preferences.enableVU ? NSOnState : NSOffState
        
        let passthroughItem = NSMenuItem(title: NSLocalizedString("Don't Own Media Keys", comment: "Don't Own Media Keys"), action: #selector(toggleMediaKeysPassthrough(_:)), keyEquivalent: "")
        passthroughItem.target = self
        passthroughItem.state = Preferences.mediaKeysPassthroughEnabled ? NSOnState : NSOffState
        
        let updateItem = NSMenuItem(title: NSLocalizedString("Check for Updates…", comment: "Check for Updates"), action: #selector(checkForUpdates(_:)), keyEquivalent: "")
        updateItem.target = self
        
        let quitItem = NSMenuItem(title: NSLocalizedString("Quit", comment: "Quit"), action: #selector(NSApplication.terminate(_:)), keyEquivalent: "")
        quitItem.target = NSApp
        
        configMenu.addItem(reloadItem)
        configMenu.addItem(NSMenuItem.separator())
        configMenu.addItem(vuItem)
        configMenu.addItem(passthroughItem)
        configMenu.addItem(NSMenuItem.separator())
        configMenu.addItem(updateItem)
        configMenu.addItem(quitItem)
    }
    
    @objc fileprivate func showConfigMenu() {
        configMenu.popUp(positioning: nil, at: NSZeroPoint, in: configMenuButton)
    }
    
    @objc fileprivate func reload(_ sender: NSMenuItem) {
        webView.reload()
    }
    
    @objc fileprivate func toggleReflectAudioLevelInIcon(_ sender: NSMenuItem) {
        sender.state = sender.state == NSOnState ? NSOffState : NSOnState
        Preferences.enableVU = (sender.state == NSOnState)
    }
    
    @objc fileprivate func toggleMediaKeysPassthrough(_ sender: NSMenuItem) {
        sender.state = sender.state == NSOnState ? NSOffState : NSOnState
        Preferences.mediaKeysPassthroughEnabled = (sender.state == NSOnState)
    }
    
    @objc fileprivate func checkForUpdates(_ sender: NSMenuItem) {
        SUUpdater.shared().checkForUpdates(sender)
    }
    
}
