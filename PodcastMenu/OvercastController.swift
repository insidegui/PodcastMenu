//
//  OvercastController.swift
//  PodcastMenu
//
//  Created by Guilherme Rambo on 10/05/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa
import WebKit

protocol OvercastLoudnessDelegate {
    func loudnessDidChange(value: Double)
}

class OvercastController: NSObject, WKNavigationDelegate {

    enum Notifications: String, NotificationsBase {
        case OvercastDidPlay
        case OvercastDidPause
    }
    
    var loudnessDelegate: OvercastLoudnessDelegate?
    
    private let webView: WKWebView
    private let bridge: OvercastJavascriptBridge
    
    private var mediaKeysHandler = MediaKeysHandler()
    
    private lazy var userScript: WKUserScript = {
        let source = try! String(contentsOfURL: NSBundle.mainBundle().URLForResource("overcast", withExtension: "js")!)
        
        return WKUserScript(source: source, injectionTime: .AtDocumentEnd, forMainFrameOnly: true)
    }()
    
    private lazy var lookUserScript: WKUserScript = {
        let source = try! String(contentsOfURL: NSBundle.mainBundle().URLForResource("look", withExtension: "js")!)
        
        return WKUserScript(source: source, injectionTime: .AtDocumentEnd, forMainFrameOnly: false)
    }()
    
    init(webView: WKWebView) {
        self.webView = webView
        self.bridge = OvercastJavascriptBridge(webView: webView)
        
        super.init()
        
        self.bridge.callback = callLoudnessDelegate
        
        webView.navigationDelegate = self
        
        mediaKeysHandler.playPauseHandler = handlePlayPauseButton
        mediaKeysHandler.forwardHandler = handleForwardButton
        mediaKeysHandler.backwardHandler = handleBackwardButton
        
        webView.configuration.userContentController.addUserScript(lookUserScript)
        webView.configuration.userContentController.addUserScript(userScript)
        
        Notifications.OvercastDidPlay.subscribe(startActivityIfNeeded)
        Notifications.OvercastDidPause.subscribe(stopActivity)
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
    
    private var isPaused = false
    
    private func handlePlayPauseButton() {
        if isPaused {
            webView.evaluateJavaScript("document.querySelector('audio').play()", completionHandler: nil)
        } else {
            webView.evaluateJavaScript("document.querySelector('audio').pause()", completionHandler: nil)
        }
        
        isPaused = !isPaused
    }
    
    private func handleForwardButton() {
        webView.evaluateJavaScript("document.querySelector('#seekforwardbutton').click()", completionHandler: nil)
    }
    
    private func handleBackwardButton() {
        webView.evaluateJavaScript("document.querySelector('#seekbackbutton').click()", completionHandler: nil)
    }
    
    private func callLoudnessDelegate(value: Double) {
        loudnessDelegate?.loudnessDidChange(value)
    }
    
    // MARK: - Activity
    
    private var activity: NSObjectProtocol?
    
    private func startActivityIfNeeded() {
        guard activity == nil else { return }
        
        activity = NSProcessInfo.processInfo().beginActivityWithOptions([.UserInitiated, .AutomaticTerminationDisabled, .SuddenTerminationDisabled, .IdleSystemSleepDisabled], reason: "PodcastMenu")
        
        #if DEBUG
        NSLog("[OvercastController] Started activity \(activity)")
        #endif
    }
    private func stopActivity() {
        guard let activity = activity else { return }
        
        #if DEBUG
        NSLog("[OvercastController] Stopping activity \(activity)")
        #endif
        
        NSProcessInfo.processInfo().endActivity(activity)
        
        self.activity = nil
    }
    
}

private class OvercastJavascriptBridge: NSObject, WKScriptMessageHandler {
    
    var callback: (Double) -> () = { _ in }
    
    private var fakeGenerator: FakeLoudnessDataGenerator!
    
    init(webView: WKWebView) {
        super.init()
        
        webView.configuration.userContentController.addScriptMessageHandler(self, name: Constants.javascriptBridgeName)
    }
    
    @objc private func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        guard let msg = message.body as? String else { return }
        
        dispatch_async(dispatch_get_main_queue()) {
            switch msg {
            case "pause": self.didPause()
            case "play": self.didPlay()
            default: break;
            }
        }
        
        /* JS-based VU disabled because of webkit bug (issue #3)
        guard let value = message.body as? Double else { return }
        
        dispatch_async(dispatch_get_main_queue()) {
            self.callback(value)
        }
         */
    }
    
    private func didPause() {
        guard fakeGenerator != nil else { return }
        
        OvercastController.Notifications.OvercastDidPause.post()
        
        dispatch_async(dispatch_get_main_queue()) {
            self.fakeGenerator.suspend()
        }
    }
    
    private func didPlay() {
        if fakeGenerator == nil { fakeGenerator = FakeLoudnessDataGenerator(callback: callback) }
        
        OvercastController.Notifications.OvercastDidPlay.post()
        
        dispatch_async(dispatch_get_main_queue()) {
            self.fakeGenerator.resume()
        }
    }
    
}

private class FakeLoudnessDataGenerator {
    
    private let callback: (Double) -> ()
    private var timer: NSTimer!
    
    init(callback: (Double) -> ()) {
        self.callback = callback
    }
    
    func resume() {
        guard timer == nil else { return }
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(generate), userInfo: nil, repeats: true)
    }
    
    func suspend() {
        guard timer != nil else { return }
        
        timer.invalidate()
        timer = nil
    }
    
    private var minValue = 22.0
    private var maxValue = 100.0
    private var stepValue = 4.0
    private var currentValue = 0.0
    private var direction = 1
    
    @objc private func generate() {
        let step = (stepValue + stepValue * drand48()) * Double(direction)
        currentValue += step
        
        if (currentValue >= maxValue) {
            direction = -1
        } else if (currentValue <= minValue) {
            direction = 1
        }
        
        callback(currentValue)
    }
}