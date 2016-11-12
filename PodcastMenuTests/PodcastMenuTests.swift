//
//  PodcastMenuTests.swift
//  PodcastMenuTests
//
//  Created by Guilherme Rambo on 11/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import XCTest
@testable import PodcastMenu

class PodcastMenuTests: XCTestCase {
    
    private lazy var testEpisodesData: Data = {
        let url = Bundle(for: PodcastMenuTests.self).url(forResource: "Episodes", withExtension: "json")!
        return try! Data(contentsOf: url)
    }()

    private lazy var testPodcastsData: Data = {
        let url = Bundle(for: PodcastMenuTests.self).url(forResource: "Podcasts", withExtension: "json")!
        return try! Data(contentsOf: url)
    }()
    
    private lazy var expectedTestEpisodeDate: Date = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en-US")
        formatter.dateFormat = "MMM dd, yyyy"
        
        return formatter.date(from: "nov 10, 2016")!
    }()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testParsingPodcasts() {
        let result = PodcastsAdapter(input: JSON(data: testPodcastsData)).adapt()
        
        switch result {
        case .error(let error):
            XCTFail("Expected to succeed but failed with error \(error)")
        case .success(let podcasts):
            guard podcasts.count == 47 else {
                XCTFail("Podcasts count should be 47, got \(podcasts.count)")
                return
            }
            
            let podcast = podcasts[2]
            XCTAssertEqual(podcast.name, "Anxious Machine")
            XCTAssertEqual(podcast.link, URL(string: "https://overcast.fm/itunes928943009/anxious-machine"))
            XCTAssertEqual(podcast.poster, URL(string: "http://static.libsyn.com/p/assets/e/d/c/0/edc0c8516a5923c2/am-3000.jpg"))
        }
    }
    
    func testParsingEpisodes() {
        let result = EpisodesAdapter(input: JSON(data: testEpisodesData)).adapt()
        
        switch result {
        case .error(let error):
            XCTFail("Expected to succeed but failed with error \(error)")
        case .success(let episodes):
            guard episodes.count == 9 else {
                XCTFail("Episodes count should be 9, got \(episodes.count)")
                return
            }
            
            let episode = episodes[1]
            
            XCTAssertEqual(episode.podcast.name, "build phase")
            XCTAssertEqual(episode.podcast.poster, URL(string: "https://media.simplecast.com/podcast/image/272/1437489285-artwork.jpg")!)
            XCTAssertEqual(episode.title, "112: Embarrassment Factor")
            XCTAssertEqual(episode.link, URL(string: "https://overcast.fm/+F7xkKwdCw")!)
            XCTAssertEqual(episode.date, expectedTestEpisodeDate)
            
            switch episode.time {
            case .duration(_): XCTFail("Expected time type to be \"remaining\"")
            case .remaining(let time): XCTAssertEqual(time, "00:55:25")
            }
        }
    }
    
}
