//
//  ScrubberRemoteImageItemView.swift
//  PodcastMenu
//
//  Created by Guilherme Rambo on 12/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa

@available(OSX 10.12.2, *)
class ScrubberRemoteImageItemView: NSScrubberImageItemView {
    
    var indexInScrubber: Int = -1
    
    var imageUrl: URL? {
        didSet {
            guard imageUrl != nil, superview != nil else { return }
            
            displayImage()
        }
    }
    
    override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        
        displayImage()
    }
    
    private var cancelDownload: ImageCache.CancellationHandler?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cancelDownload?()
    }
    
    private func displayImage() {
        guard let imageUrl = imageUrl else { return }
        
        let imageUrlWhenDownloadStarted = imageUrl
        
        cancelDownload = ImageCache.shared.fetchImage(at: imageUrl) { [weak self] _, image in
            guard let welf = self else { return }
            
            guard imageUrlWhenDownloadStarted == welf.imageUrl else {
                #if DEBUG
                    NSLog("Skipped setting scrubber item image because the URL changed \(imageUrlWhenDownloadStarted)")
                #endif
                return
            }
            guard let image = image else { return }
            
            welf.image = image
        }
    }
    
}
