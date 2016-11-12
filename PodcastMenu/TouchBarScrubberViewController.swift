//
//  TouchBarScrubberViewController.swift
//  PodcastMenu
//
//  Created by Guilherme Rambo on 12/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa

private final class ScrubberItem: NSObject {
    
    let episode: Episode?
    let podcast: Podcast?
    
    init(episode: Episode? = nil, podcast: Podcast? = nil) {
        self.episode = episode
        self.podcast = podcast
        
        super.init()
    }
    
    var poster: URL {
        return episode?.poster ?? podcast!.poster
    }
    
    var link: URL {
        return episode?.link ?? podcast!.link!
    }
    
}

@available(OSX 10.12.1, *)
class TouchBarScrubberViewController: NSViewController {

    init() {
        super.init(nibName: nil, bundle: nil)!
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = NSView()
        view.addSubview(scrubber)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrubber.register(ScrubberRemoteImageItemView.self, forItemIdentifier: Constants.itemIdentifier)
    }
    
    var currentEpisodeTitle: String? = nil {
        didSet {
            currentEpisode = episodes.first(where: { $0.title == self.currentEpisodeTitle })
        }
    }
    
    var currentEpisode: Episode? = nil {
        didSet {
            guard let index = items.index(where: { $0.episode?.title == currentEpisode?.title }) else { return }
            
            scrubber.selectedIndex = index
        }
    }
    
    var episodes: [Episode] = [] {
        didSet {
            consolidateItems()
        }
    }
    
    var podcasts: [Podcast] = [] {
        didSet {
            consolidateItems()
        }
    }
    
    private func consolidateItems() {
        let episodeItems = episodes.map({ ScrubberItem(episode: $0, podcast: nil) })
        let podcastItems = podcasts.map({ ScrubberItem(episode: nil, podcast: $0) })
        
        items = episodeItems + podcastItems
    }
    
    fileprivate var items: [ScrubberItem] = [] {
        didSet {
            DispatchQueue.main.async {
                self.scrubber.reloadData()
            }
        }
    }
    
    private lazy var scrubber: NSScrubber = {
        let s = NSScrubber()
        
        let layout = NSScrubberFlowLayout()
        layout.itemSize = NSSize(width: 30, height: 30)
        layout.itemSpacing = 1.0
        
        s.scrubberLayout = layout
        s.selectionOverlayStyle = .outlineOverlay
        s.mode = .fixed
        s.showsAdditionalContentIndicators = true
        s.isContinuous = true
        s.dataSource = self
        s.delegate = self
        s.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
        
        return s
    }()
    
    fileprivate lazy var imageCache = ImageCache()
    
}

@available(OSX 10.12.1, *)
extension TouchBarScrubberViewController: NSScrubberDataSource, NSScrubberDelegate {
    
    struct Constants {
        static let itemIdentifier = "scrubberItem"
    }
    
    func numberOfItems(for scrubber: NSScrubber) -> Int {
        return items.count
    }
    
    func scrubber(_ scrubber: NSScrubber, viewForItemAt index: Int) -> NSScrubberItemView {
        var item = scrubber.makeItem(withIdentifier: Constants.itemIdentifier, owner: scrubber) as? ScrubberRemoteImageItemView
        
        if item == nil {
            item = ScrubberRemoteImageItemView()
            item?.identifier = Constants.itemIdentifier
            item?.imageAlignment = .alignTop
        }
        
        item?.imageUrl = items[index].poster
        
        return item!
    }
    
    func scrubber(_ scrubber: NSScrubber, didSelectItemAt selectedIndex: Int) {
        // TODO: play selected episode?
    }
    
}
