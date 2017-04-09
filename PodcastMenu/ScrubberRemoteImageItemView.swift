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

    fileprivate lazy var imageCache = ImageCache()
    
    var imageUrl: URL? {
        didSet {
            guard let imageUrl = imageUrl else { return }
            
            imageCache.fetchImage(at: imageUrl) { [weak self] url, image in
                guard url == self?.imageUrl else { return }
                guard let image = image else { return }
                
                self?.image = image
            }
        }
    }
    
}
