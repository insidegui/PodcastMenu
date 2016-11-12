//
//  EpisodeAdapter.swift
//  PodcastMenu
//
//  Created by Guilherme Rambo on 11/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation

final class EpisodeAdapter: Adapter<JSON, Episode> {
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        
        formatter.locale = Locale(identifier: "en-US")
        formatter.dateFormat = "MMM dd, yyyy"
        
        return formatter
    }()
    
    override func adapt() -> Result<Episode, AdapterError> {
        let podcastResult = PodcastAdapter(input: input["podcast"]).adapt()
        
        var podcast: Podcast!
        
        switch podcastResult {
        case .error(let error): return .error(error)
        case .success(let pod): podcast = pod
        }
        
        guard let title = input["title"].string else {
            return .error(.missingRequiredFields)
        }

        guard let poster = input["poster"].string else {
            return .error(.missingRequiredFields)
        }
        
        guard let link = input["link"].string else {
            return .error(.missingRequiredFields)
        }
        
        guard let timeType = input["time"]["type"].string else {
            return .error(.missingRequiredFields)
        }

        guard let timeValue = input["time"]["value"].string else {
            return .error(.missingRequiredFields)
        }
        
        guard let dateStr = input["date"].string else {
            return .error(.missingRequiredFields)
        }
        
        guard let date = dateFormatter.date(from: dateStr) else {
            return .error(.missingRequiredFields)
        }
        
        var time: Episode.Time
        
        switch timeType {
        case "remaining": time = Episode.Time.remaining(timeValue)
        default: time = Episode.Time.duration(timeValue)
        }
        
        let episode = Episode(
            podcast: podcast,
            title: title,
            poster: URL(string: poster)!,
            date: date,
            time: time,
            link: URL(string: link)!
        )
        
        return .success(episode)
    }
    
}

final class EpisodesAdapter: Adapter<JSON, [Episode]> {
    
    override func adapt() -> Result<[Episode], AdapterError> {
        guard let jsonEpisodes = input.array else {
            return .error(.missingRequiredFields)
        }
        
        let episodes: [Episode] = jsonEpisodes.flatMap { json -> Episode? in
            let result = EpisodeAdapter(input: json).adapt()
            switch result {
            case .error(_): return nil
            case .success(let episode): return episode
            }
        }
        
        return .success(episodes)
    }
    
}
