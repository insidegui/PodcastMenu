//
//  TouchBarController.swift
//  PodcastMenu
//
//  Created by Guilherme Rambo on 12/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa
import WebKit

class TouchBarController: NSObject {

    let webView: WKWebView
    
    init(webView: WKWebView) {
        self.webView = webView
        
        super.init()
        
        self.webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack), options: [.initial, .new], context: nil)
        self.webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward), options: [.initial, .new], context: nil)
    }
    
    @available(OSX 10.12.2, *)
    lazy var scrubberController = TouchBarScrubberViewController()
    
    var currentEpisodeTitle: String? = nil {
        didSet {
            if #available(OSX 10.12.2, *) {
                scrubberController.currentEpisodeTitle = currentEpisodeTitle
            }
        }
    }
    
    var episodes: [Episode] = [] {
        didSet {
            if #available(OSX 10.12.2, *) {
                scrubberController.episodes = episodes
            }
        }
    }
    
    var podcasts: [Podcast] = [] {
        didSet {
            if #available(OSX 10.12.2, *) {
                scrubberController.podcasts = podcasts
            }
        }
    }
    
    @available(OSX 10.12.2, *)
    lazy var backButton: NSButton = {
        return NSButton(title: "", image: NSImage(named: NSImageNameTouchBarGoBackTemplate)!, target: nil, action: #selector(WKWebView.goBack(_:)))
    }()
    
    @available(OSX 10.12.2, *)
    lazy var forwardButton: NSButton = {
        return NSButton(title: "", image: NSImage(named: NSImageNameTouchBarGoForwardTemplate)!, target: nil, action: #selector(WKWebView.goForward(_:)))
    }()
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.canGoBack) {
            if #available(OSX 10.12.2, *) {
                backButton.isEnabled = webView.canGoBack;
            }
        } else if keyPath == #keyPath(WKWebView.canGoForward) {
            if #available(OSX 10.12.2, *) {
                forwardButton.isEnabled = webView.canGoForward;
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    @available(OSX 10.12.2, *)
    fileprivate lazy var nowPlayingTouchBar: NSTouchBar = {
        let bar = NSTouchBar()
        
        bar.delegate = self
        bar.defaultItemIdentifiers = [.backButton, .forwardButton, .scrubber, .otherItemsProxy]
        
        return bar
    }()
    
    @available(OSX 10.12.2, *)
    func installControlStripNowPlayingItem() {
        let nowPlayingItem = NSCustomTouchBarItem(identifier: .nowPlayingControlStrip)
        nowPlayingItem.view = NSButton(image: #imageLiteral(resourceName: "controlStripIcon"), target: self, action: #selector(nowPlayingItemActivated))
        NSTouchBarItem.addSystemTrayItem(nowPlayingItem)
        
        DFRElementSetControlStripPresenceForIdentifier(NSTouchBarItemIdentifier.nowPlayingControlStrip.rawValue, true);
    }
    
    @available(OSX 10.12.2, *)
    @objc private func nowPlayingItemActivated(_ sender: Any) {
        showTouchBar()
    }
    
    @available(OSX 10.12.2, *)
    func showTouchBar() {
        NSTouchBar.presentSystemModalFunctionBar(nowPlayingTouchBar, placement: 0, systemTrayItemIdentifier: "otherTouchBar")
    }
    
    @available(OSX 10.12.2, *)
    func hideTouchBar() {
        NSTouchBar.dismissSystemModalFunctionBar(nowPlayingTouchBar)
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack))
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward))
    }
    
}

@available(OSX 10.12.2, *)
extension NSTouchBarItemIdentifier {
    static let backButton = NSTouchBarItemIdentifier("br.com.guilhermerambo.podcastmenu.back")
    static let forwardButton = NSTouchBarItemIdentifier("br.com.guilhermerambo.podcastmenu.forward")
    static let scrubber = NSTouchBarItemIdentifier("br.com.guilhermerambo.podcastmenu.scrubber")
    static let nowPlayingControlStrip = NSTouchBarItemIdentifier("br.com.guilhermerambo.podcastmenu.nowPlaying")
}

@available(OSX 10.12.2, *)
extension TouchBarController: NSTouchBarDelegate {
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItemIdentifier) -> NSTouchBarItem? {
        switch identifier {
        case NSTouchBarItemIdentifier.backButton:
            let item = NSCustomTouchBarItem(identifier: .backButton)
            item.view = backButton
            return item
        case NSTouchBarItemIdentifier.forwardButton:
            let item = NSCustomTouchBarItem(identifier: .forwardButton)
            item.view = forwardButton
            return item
        case NSTouchBarItemIdentifier.scrubber:
            let item = NSCustomTouchBarItem(identifier: .scrubber)
            item.viewController = scrubberController
            return item
        default: return nil
        }
    }
    
}
