//
//  PodcastAdapter.swift
//  PodcastMenu
//
//  Created by Guilherme Rambo on 11/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation

final class PodcastAdapter: Adapter<[String: String], Podcast> {
    
}


final class PodcastsAdapter: Adapter<[[String: String]], [Podcast]> {
    
    override func adapt() -> Result<[Podcast], AdapterError> {
        let podcasts: [Podcast] = input.flatMap { dict -> Podcast? in
            let result = PodcastAdapter(input: dict).adapt()
            switch result {
            case .error(_): return nil
            case .success(let podcast): return podcast
            }
        }
        
        return .success(podcasts)
    }
    
}
