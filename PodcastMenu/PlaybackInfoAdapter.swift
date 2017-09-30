//
//  PlaybackInfoAdapter.swift
//  PodcastMenu
//
//  Created by Guilherme Rambo on 09/04/17.
//  Copyright © 2017 Guilherme Rambo. All rights reserved.
//

import Foundation

final class PlaybackInfoAdapter: Adapter<JSON, PlaybackInfo> {
    
    override func adapt() -> Result<PlaybackInfo, AdapterError> {
        guard let title = input["title"].string else {
            return .error(.missingRequiredFields)
        }
        
        guard let timeElapsed = input["time_elapsed"].string else {
            return .error(.missingRequiredFields)
        }
        
        guard let timeRemaining = input["time_remaining"].string else {
            return .error(.missingRequiredFields)
        }
        
        guard let shareLink = input["share_link"].string,
            let shareURL = URL(string: shareLink)  else {
            return .error(.missingRequiredFields)
        }

        guard let shareLinkWithTimestamp = input["share_link_timestamp"].string,
            let shareWithTimeURL = URL(string: shareLinkWithTimestamp) else {
            return .error(.missingRequiredFields)
        }
        
        guard let audioSource = input["audio_source"].string,
            let audioURL = URL(string: audioSource) else {
            return .error(.missingRequiredFields)
        }
        
        guard let artworkSource = input["artwork_url"].string,
            let artworkURL = URL(string: artworkSource) else {
                return .error(.missingRequiredFields)
        }
        
        let info = PlaybackInfo(title: title,
                                timeElapsed: timeElapsed,
                                timeRemaining: timeRemaining,
                                audioURL: audioURL,
                                shareURL: shareURL,
                                shareWithTimeURL: shareWithTimeURL,
                                artworkURL: artworkURL)
        
        return .success(info)
    }
    
}
