//
//  PodcastAdapter.swift
//  PodcastMenu
//
//  Created by Guilherme Rambo on 11/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation
import SwiftyJSON

final class PodcastAdapter: Adapter<JSON, Podcast> {
    
    override func adapt() -> Result<Podcast, AdapterError> {
        guard let name = input["name"].string else {
            return .error(.missingRequiredFields)
        }
        
        guard let poster = input["poster"].string?.overcastPoster else {
            return .error(.missingRequiredFields)
        }
        
        let link = input["link"].stringValue
        
        let podcast = Podcast(name: name, poster: poster, link: URL(string: link))
        
        return .success(podcast)
    }
    
}


final class PodcastsAdapter: Adapter<JSON, [Podcast]> {
    
    override func adapt() -> Result<[Podcast], AdapterError> {
        guard let jsonPodcasts = input.array else {
            return .error(.missingRequiredFields)
        }
        
        let podcasts: [Podcast] = jsonPodcasts.flatMap { json -> Podcast? in
            let result = PodcastAdapter(input: json).adapt()
            switch result {
            case .error(_): return nil
            case .success(let podcast): return podcast
            }
        }
        
        return .success(podcasts)
    }
    
}
