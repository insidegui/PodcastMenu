//
//  OvercastController.swift
//  PodcastMenu
//
//  Created by Guilherme Rambo on 10/05/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa
import WebKit

class OvercastController: NSObject, WKNavigationDelegate {

    private let webView: WKWebView
    
    private var mediaKeysHandler = MediaKeysHandler()
    
    private lazy var userscript: WKUserScript = {
        let source = try! String(contentsOfURL: NSBundle.mainBundle().URLForResource("overcast", withExtension: "js")!)
        
        return WKUserScript(source: source, injectionTime: .AtDocumentEnd, forMainFrameOnly: true)
    }()
    
    init(webView: WKWebView) {
        self.webView = webView
        
        super.init()
        
        webView.navigationDelegate = self
        
        mediaKeysHandler.playPauseHandler = handlePlayPauseButton
        mediaKeysHandler.forwardHandler = handleForwardButton
        mediaKeysHandler.backwardHandler = handleBackwardButton
        
        webView.configuration.userContentController.addUserScript(userscript)
    }
    
    func isValidOvercastURL(URL: NSURL) -> Bool {
        guard let host = URL.host else { return false }
        
        return Constants.allowedHosts.contains(host)
    }
    
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        // the default is to allow the navigation
        var decision = WKNavigationActionPolicy.Allow
        
        defer { decisionHandler(decision) }
        
        guard navigationAction.navigationType == .LinkActivated else { return }
        
        guard let URL = navigationAction.request.URL else { return }
        
        // if the user clicked a link to another website, open with the default browser instead of navigating inside the app
        guard isValidOvercastURL(URL) else {
            decision = .Cancel
            NSWorkspace.sharedWorkspace().openURL(URL)
            return
        }
    }
    
    private func handlePlayPauseButton() {
        webView.evaluateJavaScript("document.querySelector('audio').paused ? document.querySelector('audio').play() : document.querySelector('audio').pause()", completionHandler: nil)
    }
    
    private func handleForwardButton() {
        webView.evaluateJavaScript("document.querySelector('#seekforwardbutton').click()", completionHandler: nil)
    }
    
    private func handleBackwardButton() {
        webView.evaluateJavaScript("document.querySelector('#seekbackbutton').click()", completionHandler: nil)
    }
    
}
