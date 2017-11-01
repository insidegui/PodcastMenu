//
//  PlaybackInfo.swift
//  PodcastMenu
//
//  Created by Guilherme Rambo on 09/04/17.
//  Copyright © 2017 Guilherme Rambo. All rights reserved.
//

import Foundation

struct PlaybackInfo {
    
    let title: String
    let timeElapsed: String
    let timeRemaining: String
    let audioURL: URL
    let shareURL: URL
    let shareWithTimeURL: URL
    let artworkURL: URL
    let isPlaying: Bool
    
}

extension PlaybackInfo: Equatable {
    
    static func ==(lhs: PlaybackInfo, rhs: PlaybackInfo) -> Bool {
        return lhs.title == rhs.title
            && lhs.timeElapsed == rhs.timeElapsed
            && lhs.timeRemaining == rhs.timeRemaining
            && lhs.audioURL == rhs.audioURL
            && lhs.shareURL == rhs.shareURL
            && lhs.shareWithTimeURL == rhs.shareWithTimeURL
            && lhs.artworkURL == rhs.artworkURL
            && lhs.isPlaying == rhs.isPlaying
    }
    
}
