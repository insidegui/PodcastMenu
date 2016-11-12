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
    
    var currentEpisodeTitle: String? = nil {
        didSet {
            currentEpisode = episodes.first(where: { $0.title == self.currentEpisodeTitle })
        }
    }
    
    var currentEpisode: Episode? = nil {
        didSet {
            DispatchQueue.main.async {
                print("NOW PLAYING: \(self.currentEpisode)")
            }
        }
    }
    
    var episodes: [Episode] = [] {
        didSet {
            DispatchQueue.main.async {
                print(self.episodes)
            }
        }
    }
    
    var podcasts: [Podcast] = [] {
        didSet {
            DispatchQueue.main.async {
                print(self.podcasts)
            }
        }
    }
    
    @available(OSX 10.12.1, *)
    lazy var backButton: NSButton = {
        return NSButton(title: "", image: NSImage(named: NSImageNameTouchBarGoBackTemplate)!, target: nil, action: #selector(WKWebView.goBack(_:)))
    }()
    
    @available(OSX 10.12.1, *)
    lazy var forwardButton: NSButton = {
        return NSButton(title: "", image: NSImage(named: NSImageNameTouchBarGoForwardTemplate)!, target: nil, action: #selector(WKWebView.goForward(_:)))
    }()
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.canGoBack) {
            if #available(OSX 10.12.1, *) {
                backButton.isEnabled = webView.canGoBack;
            }
        } else if keyPath == #keyPath(WKWebView.canGoForward) {
            if #available(OSX 10.12.1, *) {
                forwardButton.isEnabled = webView.canGoForward;
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack))
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward))
    }
    
}

@available(OSX 10.12.1, *)
extension NSTouchBarItemIdentifier {
    static let backButton = NSTouchBarItemIdentifier("br.com.guilhermerambo.podcastmenu.back")
    static let forwardButton = NSTouchBarItemIdentifier("br.com.guilhermerambo.podcastmenu.forward")
    static let scrubber = NSTouchBarItemIdentifier("br.com.guilhermerambo.podcastmenu.scrubber")
}

@available(OSX 10.12.1, *)
extension TouchBarController: NSTouchBarProvider {
    
    var touchBar: NSTouchBar? {
        let bar = NSTouchBar()
        
        bar.delegate = self
        bar.defaultItemIdentifiers = [.backButton, .forwardButton, .scrubber, .otherItemsProxy]
        
        return bar
    }
    
}

@available(OSX 10.12.1, *)
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
        default: return nil
        }
    }
    
}
