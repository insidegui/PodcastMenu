//
//  PMWebView.swift
//  WebView Tests
//
//  Created by Guilherme Rambo on 13/05/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa
import WebKit

class PMWebView: WKWebView {

    private var scrollTimer: NSTimer!
    private lazy var scrollCaptureView = PMScrollCaptureView(frame: NSZeroRect)
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        
        guard scrollCaptureView.superview == nil else { return }
        guard subviews.count > 0 else { return }
        
        scrollCaptureView.webView = self
        scrollCaptureView.frame = bounds
        scrollCaptureView.autoresizingMask = [.ViewWidthSizable, .ViewHeightSizable]
        subviews[0].addSubview(scrollCaptureView)
    }
    
    private func didScroll() {
        showScrollbar()
        resetScrollTimer()
    }
    
    private func resetScrollTimer() {
        if scrollTimer != nil {
            scrollTimer.invalidate()
            scrollTimer = nil
        }
        
        scrollTimer = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: #selector(hideScrollbar), userInfo: nil, repeats: false)
    }
    
    @objc private func hideScrollbar() {
        evaluateJavaScript("PodcastMenuLook.hideScroll()", completionHandler: nil)
    }
    
    private func showScrollbar() {
        evaluateJavaScript("PodcastMenuLook.showScroll()", completionHandler: nil)
    }
    
}

private class PMScrollCaptureView: NSView {
    
    private var webView: PMWebView!
    
    private override func scrollWheel(theEvent: NSEvent) {
        // cancel horizontal scrolling
        guard fabs(theEvent.scrollingDeltaX) < fabs(theEvent.scrollingDeltaY) else { return }
        
        webView.didScroll()
        
        superview?.scrollWheel(theEvent)
    }
    
}