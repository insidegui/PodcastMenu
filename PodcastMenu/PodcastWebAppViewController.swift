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
import SwiftyJSON

class PodcastWebAppViewController: NSViewController {
    
    var loudnessDelegate: OvercastLoudnessDelegate?
    var currentEpisodes: [Episode] = []
    
    
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
        let b = PMFreestandingButton(frame: NSZeroRect)
        
        b.translatesAutoresizingMaskIntoConstraints = false
        b.isBordered = false
        b.bezelStyle = NSBezelStyle.inline
        b.image = NSImage(named: NSImageNameActionTemplate)
        b.toolTip = NSLocalizedString("Options", comment: "Options menu tooltip")
        b.sendAction(on: .leftMouseDown)
        b.imagePosition = .imageOnly
        
        b.sizeToFit()
        
        return b
    }()
    
    fileprivate lazy var shareButton: NSButton = {
        let b = PMFreestandingButton(frame: NSZeroRect)
        
        b.translatesAutoresizingMaskIntoConstraints = false
        b.isBordered = false
        b.bezelStyle = .inline
        b.image = NSImage(named: NSImageNameShareTemplate)
        b.toolTip = NSLocalizedString("Share", comment: "Share button tooltip")
        b.sendAction(on: .leftMouseDown)
        b.imagePosition = .imageOnly
        
        b.sizeToFit()
        b.isHidden = true
        
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
        webView.alphaValue = 0
        
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
        
        view.addSubview(configMenuButton)
        
        configMenuButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Metrics.controlToWindowMargin).isActive = true
        configMenuButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Metrics.controlToWindowMargin).isActive = true
        
        shareButton.target = self
        shareButton.action = #selector(share(_:))
        
        view.addSubview(shareButton)
        
        shareButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Metrics.controlToWindowMargin).isActive = true
        shareButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Metrics.controlToWindowMargin).isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overcastController = OvercastController(webView: webView)
        overcastController.loudnessDelegate = loudnessDelegate
        
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: [.initial, .new], context: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(propagatePlaybackInfo(_:)), name: .OvercastShouldUpdatePlaybackInfo, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopPlaybackInfoPropagation(_:)), name: .OvercastIsNotOnEpisodePage, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateAppearance), name: .SystemAppearanceDidChange, object: nil)
        
        webView.load(URLRequest(url: Constants.webAppURL as URL))
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        view.window?.alphaValue = 1.0
        updateAppearance()
        
        if #available(OSX 10.12.2, *) {
            touchBarController.installControlStripNowPlayingItem()
            touchBarController.showTouchBar()
        }
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        if #available(OSX 10.12.2, *) {
            touchBarController.hideTouchBar()
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            if webView.estimatedProgress >= 0.99 {
                webViewDidFinishLoadingPage()
            }
            if webView.estimatedProgress > 0.4 {
                webView.animator().alphaValue = 1
                updateAppearance()
            }
            progressBar.progress = webView.estimatedProgress
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    func openURL(_ URL: Foundation.URL) {
        guard overcastController.isValidOvercastURL(URL) else {
            NSWorkspace.shared().open(URL)
            return
        }
        
        webView.load(URLRequest(url: URL))
    }
    
    // MARK: - Appearance
    
    @objc private func updateAppearance() {
        view.window?.appearance = Theme.appearance
        view.window?.backgroundColor = Theme.Colors.background
        
        configMenuButton.appearance = Theme.appearance
        shareButton.appearance = Theme.appearance
        
        progressBar.tintColor = Theme.Colors.tint
        
        webView.evaluateJavaScript("PodcastMenuLook.toggleDarkMode(\(Theme.isDark));", completionHandler: nil)
    }

    // MARK: - Touch Bar

    fileprivate lazy var touchBarController: TouchBarController = {
        let c = TouchBarController(webView: self.webView)
        
        if #available(macOS 10.12.2, *) {
            c.scrubberController.delegate = self
        }
        
        return c
    }()
    
    private lazy var episodesParserScript: String? = {
        guard let url = Bundle.main.url(forResource: "EpisodesParser", withExtension: "js") else { return nil }
        
        guard let data = try? Data(contentsOf: url) else { return nil }

        return String(data: data, encoding: .utf8)
    }()
    
    private lazy var podcastsParserScript: String? = {
        guard let url = Bundle.main.url(forResource: "PodcastsParser", withExtension: "js") else { return nil }
        
        guard let data = try? Data(contentsOf: url) else { return nil }
        
        return String(data: data, encoding: .utf8)
    }()
    
    private lazy var titleParserScript: String? = {
        guard let url = Bundle.main.url(forResource: "TitleParser", withExtension: "js") else { return nil }
        
        guard let data = try? Data(contentsOf: url) else { return nil }
        
        return String(data: data, encoding: .utf8)
    }()
    
    private lazy var playbackInfoParserScript: String? = {
        guard let url = Bundle.main.url(forResource: "PlaybackInfoParser", withExtension: "js") else { return nil }
        
        guard let data = try? Data(contentsOf: url) else { return nil }
        
        return String(data: data, encoding: .utf8)
    }()
    
    // MARK: Data
    
    fileprivate var isLoggedIn = false
    
    private func webViewDidFinishLoadingPage() {
        if let title = webView.title, title != Constants.homeTitle {
            // visiting a page other than the home, try to find out the title of the episode being played
            
            guard let titleParserScript = titleParserScript else { return }
            
            webView.evaluateJavaScript(titleParserScript) { [weak self] evalResult, error in
                guard error == nil else { return }
                guard let jsString = evalResult as? String else { return }
                
                self?.touchBarController.currentEpisodeTitle = jsString.isEmpty ? nil : jsString
            }
        } else {
            touchBarController.currentEpisodeTitle = nil
            
            // visiting the home page, use this chance to grab the list of episodes and podcasts for the touch bar widgets
            fetchMetadata()
        }
        
        updateAppearance()
    }
    
    private func fetchMetadata() {
        guard let episodesParserScript = episodesParserScript else { return }
        guard let podcastsParserScript = podcastsParserScript else { return }
        
        webView.evaluateJavaScript(episodesParserScript) { [weak self] evalResult, error in
            guard error == nil else { return }
            guard let jsString = evalResult as? String else { return }
            guard let jsData = jsString.data(using: .utf8) else { return }
            
            let result = EpisodesAdapter(input: JSON(data: jsData)).adapt()
            switch result {
            case .success(let episodes):
                self?.displayUserNotifcationIfNecessary(self?.currentEpisodes, currentEpisodes: episodes)
                self?.currentEpisodes = episodes
                self?.touchBarController.episodes = episodes
            default: break
            }
        }
        
        webView.evaluateJavaScript(podcastsParserScript) { [weak self] evalResult, error in
            guard error == nil else { return }
            guard let jsString = evalResult as? String else { return }
            guard let jsData = jsString.data(using: .utf8) else { return }
            
            let result = PodcastsAdapter(input: JSON(data: jsData)).adapt()
            switch result {
            case .success(let podcasts):
                self?.touchBarController.podcasts = podcasts
            default: break
            }
        }
        
        webView.evaluateJavaScript(podcastsParserScript) { [weak self] evalResult, error in
            guard error == nil else { return }
            guard let jsString = evalResult as? String else { return }
            guard let jsData = jsString.data(using: .utf8) else { return }
            
            let result = PodcastsAdapter(input: JSON(data: jsData)).adapt()
            switch result {
            case .success(let podcasts):
                self?.touchBarController.podcasts = podcasts
            default: break
            }
        }
        
        webView.evaluateJavaScript("document.querySelector('a[href=\"/account\"]') != null") { [weak self] result, error in
            guard error == nil else { return }
            
            guard let status = result as? Bool else { return }
            
            self?.isLoggedIn = status
        }
    }
    
    func fetchPlaybackInfo(completion: @escaping (Result<PlaybackInfo, AdapterError>) -> ()) {
        guard let playbackInfoParserScript = playbackInfoParserScript else { return }
        
        webView.evaluateJavaScript(playbackInfoParserScript) { evalResult, error in
            guard error == nil else { return }
            guard let jsString = evalResult as? String else { return }
            guard let jsData = jsString.data(using: .utf8) else { return }
            
            let result = PlaybackInfoAdapter(input: JSON(data: jsData)).adapt()
            
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    // MARK: - Playback Info
    
    func propagatePlaybackInfo(_ notification: Notification) {
        fetchPlaybackInfo { [weak self] result in
            switch result {
            case .success(let info):
                self?.currentPlaybackInfo = info
            case .error(let error):
                NSLog("Error updating playback info:\n\(error)")
            }
        }
    }
    
    func stopPlaybackInfoPropagation(_ notification: Notification) {
        currentPlaybackInfo = nil
        
        #if DEBUG
            NSLog("Invalidated playback info")
        #endif
    }
    
    fileprivate var currentPlaybackInfo: PlaybackInfo? {
        didSet {
            shareButton.isHidden = (currentPlaybackInfo == nil)
            
            touchBarController.playbackInfo = currentPlaybackInfo
        }
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
        
        let logOutItem = NSMenuItem(title: NSLocalizedString("Log Out", comment: "Log Out"), action: #selector(logOut(_:)), keyEquivalent: "")
        logOutItem.target = self
        logOutItem.tag = ConfigMenuItem.logOut.rawValue
        
        let updateItem = NSMenuItem(title: NSLocalizedString("Check for Updates…", comment: "Check for Updates"), action: #selector(checkForUpdates(_:)), keyEquivalent: "")
        updateItem.target = self
        
        let quitItem = NSMenuItem(title: NSLocalizedString("Quit", comment: "Quit"), action: #selector(NSApplication.terminate(_:)), keyEquivalent: "")
        quitItem.target = NSApp
        
        configMenu.addItem(reloadItem)
        
        configMenu.addItem(NSMenuItem.separator())
        configMenu.addItem(vuItem)
        configMenu.addItem(passthroughItem)
        
        configMenu.addItem(NSMenuItem.separator())
        configMenu.addItem(logOutItem)
        
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
    
    @objc fileprivate func logOut(_ sender: NSMenuItem) {
        webView.load(URLRequest(url: Constants.logOutURL))
    }
    
    // MARK: Sharing
    
    @objc fileprivate func share(_ sender: NSButton) {
        guard let info = currentPlaybackInfo else { return }
        
        let picker = NSSharingServicePicker(items: [info.shareWithTimeURL])
        picker.show(relativeTo: .zero, of: sender, preferredEdge: .minY)
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    
    // MARK: User Notifications
    
    fileprivate func displayUserNotifcationIfNecessary(_ previousEpisodes: [Episode]?, currentEpisodes:[Episode]?) {
        var newEpisodeCount = 0
        guard (previousEpisodes?.isEmpty) == false else { return }
        
        currentEpisodes?.forEach({ (episode) in
            guard (previousEpisodes?.contains(episode))! == false else { return }
            newEpisodeCount += 1
        })
        
        guard (newEpisodeCount != 0) else { return }
        self.displayUserNotifcation(newEpisodeCount: newEpisodeCount)
    }
    
    fileprivate func displayUserNotifcation(newEpisodeCount: Int ){
        let userNotification = NSUserNotification()
        userNotification.title = "New Active Episodes"
        userNotification.informativeText = newEpisodeCount > 1 ? "You have \(newEpisodeCount) new episodes" : "You have \(newEpisodeCount) new episode"
        NSUserNotificationCenter.default.deliver(userNotification)
    }
}

@available(OSX 10.12.2, *)
extension PodcastWebAppViewController: TouchBarScrubberViewControllerDelegate {
    
    func didSelectLink(_ linkURL: URL) {
        webView.load(URLRequest(url: linkURL))
    }
    
}

// MARK: Menu Validation

private enum ConfigMenuItem: Int {
    case logOut = 101
}

extension PodcastWebAppViewController: NSMenuDelegate {
    
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        guard let item = ConfigMenuItem(rawValue: menuItem.tag) else {
            return true
        }
        
        switch item {
        case .logOut:
            return isLoggedIn
        }
    }
    
}
