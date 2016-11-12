//
//  EpisodeAdapter.swift
//  PodcastMenu
//
//  Created by Guilherme Rambo on 11/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation

final class EpisodeAdapter: Adapter<[String: String], Episode> {
    
}

final class EpisodesAdapter: Adapter<[[String: String]], [Episode]> {
    
    override func adapt() -> Result<[Episode], AdapterError> {
        let episodes: [Episode] = input.flatMap { dict -> Episode? in
            let result = EpisodeAdapter(input: dict).adapt()
            switch result {
            case .error(_): return nil
            case .success(let episode): return episode
            }
        }
        
        return .success(episodes)
    }
    
}
