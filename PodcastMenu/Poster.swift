//
//  Poster.swift
//  PodcastMenu
//
//  Created by Guilherme Rambo on 12/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation

extension String {
    
    var overcastPoster: URL? {
        guard let posterComponents = URLComponents(string: self) else {
            return nil
        }
        
        guard let posterUrlString = posterComponents.queryItems?.first(where: { $0.name == "u" })?.value else {
            return nil
        }
        
        return URL(string: posterUrlString)
    }
    
}
