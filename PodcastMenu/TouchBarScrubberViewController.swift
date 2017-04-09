//
//  TouchBarScrubberViewController.swift
//  PodcastMenu
//
//  Created by Guilherme Rambo on 12/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa
import IGListDiff

@available(macOS 10.12.2, *)
private final class ScrubberItem: NSObject {
    
    let model: OvercastModel
    
    init(model: OvercastModel) {
        self.model = model
        
        super.init()
    }
    
    var poster: URL {
        return model.poster
    }
    
    var link: URL? {
        return model.link
    }
    
    override func diffIdentifier() -> NSObjectProtocol {
        return self.hash as NSObjectProtocol
    }
    
    override func isEqual(_ object: IGListDiffable?) -> Bool {
        guard let other = object as? ScrubberItem else { return false }
        
        return model.compare(to: other.model)
    }
    
}

@available(OSX 10.12.2, *)
protocol TouchBarScrubberViewControllerDelegate: class {
    
    func didSelectLink(_ linkURL: URL)
    
}

@available(OSX 10.12.2, *)
class TouchBarScrubberViewController: NSViewController {

    weak var delegate: TouchBarScrubberViewControllerDelegate?
    
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
            guard let index = items.index(where: { $0.model.title == currentEpisode?.title }) else { return }
            
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
        let models = (episodes as [OvercastModel]) + (podcasts as [OvercastModel])
        items = models.map({ ScrubberItem(model: $0) })
    }
    
    fileprivate var items: [ScrubberItem] = [] {
        didSet {
            DispatchQueue.main.async {
                if oldValue.isEmpty {
                    self.scrubber.reloadData()
                } else {
                    let diff = IGListDiff(oldValue, self.items, .equality)
                    self.scrubber.performSequentialBatchUpdates {
                        self.scrubber.removeItems(at: diff.deletes)
                        self.scrubber.insertItems(at: diff.inserts)
                        self.scrubber.reloadItems(at: diff.updates)
                    }
                }
            }
        }
    }
    
    fileprivate lazy var scrubber: NSScrubber = {
        let s = NSScrubber()
        
        let layout = NSScrubberFlowLayout()
        layout.itemSize = NSSize(width: 30, height: 30)
        layout.itemSpacing = 1.0
        
        s.scrubberLayout = layout
        s.selectionOverlayStyle = .outlineOverlay
        s.mode = .free
        s.showsAdditionalContentIndicators = true
        s.dataSource = self
        s.delegate = self
        s.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
        
        return s
    }()
    
}

@available(OSX 10.12.2, *)
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
        
        item?.indexInScrubber = index
        item?.imageUrl = items[index].poster
        
        return item ?? NSScrubberItemView()
    }
    
    func scrubber(_ scrubber: NSScrubber, didSelectItemAt selectedIndex: Int) {
        guard selectedIndex < scrubber.numberOfItems else { return }
        
        let selectedItem = items[selectedIndex]
        guard let link = selectedItem.model.link else { return }
        
        delegate?.didSelectLink(link)
    }
    
}
