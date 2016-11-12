//
//  ImageCache.swift
//  PodcastMenu
//
//  Created by Guilherme Rambo on 12/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation

private extension String {
    
    var base64encoded: String? {
        return self.data(using: .utf8)?.base64EncodedString()
    }
    
}

final class ImageCache {
    
    class func cacheUrl(for imageUrl: URL) -> URL {
        let filename = imageUrl.absoluteString.base64encoded ?? imageUrl.lastPathComponent
        
        let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first! + "/" + filename + "-" + imageUrl.lastPathComponent
        
        NSLog("\(path)")
        
        return URL(fileURLWithPath: path)
    }
    
    func fetchImage(at imageUrl: URL, completion: @escaping (URL, NSImage?) -> ()) {
        let cacheUrl = ImageCache.cacheUrl(for: imageUrl)
        
        guard !FileManager.default.fileExists(atPath: cacheUrl.path) else {
            completion(imageUrl, NSImage(contentsOfFile: cacheUrl.path))
            return
        }
        
        let task = URLSession.shared.dataTask(with: imageUrl) { data, _, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completion(imageUrl, nil)
                }
                return
            }
            
            do {
                try data.write(to: cacheUrl)
            } catch {
                NSLog("Error saving image to cache: \(error)")
            }
            
            DispatchQueue.main.async {
                completion(imageUrl, NSImage(data: data))
            }
        }
        task.resume()
    }
    
}
