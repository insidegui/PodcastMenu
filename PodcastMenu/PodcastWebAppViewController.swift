//
//  PodcastWebAppViewController.swift
//  PodcastMenu
//
//  Created by Guilherme Rambo on 10/05/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa
import WebKit

class PodcastWebAppViewController: NSViewController {
    
    init() {
        super.init(nibName: nil, bundle: nil)!
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private lazy var progressBar = ProgressBar(frame: NSZeroRect)
    private lazy var webView: WKWebView = WKWebView(frame: NSZeroRect)
    private var overcastController: OvercastController!
    
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overcastController = OvercastController(webView: webView)
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
    
}
