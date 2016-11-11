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

    fileprivate var scrollTimer: Timer!
    fileprivate lazy var scrollCaptureView = PMScrollCaptureView(frame: NSZeroRect)
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        
        guard scrollCaptureView.superview == nil else { return }
        guard subviews.count > 0 else { return }
        
        scrollCaptureView.webView = self
        scrollCaptureView.frame = bounds
        scrollCaptureView.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
        subviews[0].addSubview(scrollCaptureView)
    }
    
    fileprivate func didScroll() {
        showScrollbar()
        resetScrollTimer()
    }
    
    fileprivate func resetScrollTimer() {
        if scrollTimer != nil {
            scrollTimer.invalidate()
            scrollTimer = nil
        }
        
        scrollTimer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(hideScrollbar), userInfo: nil, repeats: false)
    }
    
    @objc fileprivate func hideScrollbar() {
        evaluateJavaScript("PodcastMenuLook.hideScroll()", completionHandler: nil)
    }
    
    fileprivate func showScrollbar() {
        evaluateJavaScript("PodcastMenuLook.showScroll()", completionHandler: nil)
    }
    
}

private class PMScrollCaptureView: NSView {
    
    fileprivate var webView: PMWebView!
    
    fileprivate override func scrollWheel(with theEvent: NSEvent) {
        // cancel horizontal scrolling
        guard fabs(theEvent.scrollingDeltaX) < fabs(theEvent.scrollingDeltaY) else { return }
        
        webView.didScroll()
        
        superview?.scrollWheel(with: theEvent)
    }
    
}
