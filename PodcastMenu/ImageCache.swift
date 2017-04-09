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
    
    static let shared: ImageCache = ImageCache()
    
    typealias CancellationHandler = () -> ()
    
    class func cacheUrl(for imageUrl: URL) -> URL {
        let filebase = imageUrl.path.replacingOccurrences(of: "/", with: "_")
        let filename = filebase + "-" + imageUrl.lastPathComponent
        
        let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first! + "/" + filename + "-" + imageUrl.lastPathComponent
        
        return URL(fileURLWithPath: path)
    }
    
    func fetchImage(at imageUrl: URL, completion: @escaping (URL, NSImage?) -> ()) -> CancellationHandler {
        let cacheUrl = ImageCache.cacheUrl(for: imageUrl)
        
        guard !FileManager.default.fileExists(atPath: cacheUrl.path) else {
            completion(imageUrl, NSImage(contentsOfFile: cacheUrl.path))
            return { }
        }
        
        let task = URLSession.shared.dataTask(with: imageUrl) { data, _, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completion(imageUrl, nil)
                }
                return
            }
            
            guard let cachedImage = self.cache(data: data, cacheURL: cacheUrl) else {
                DispatchQueue.main.async {
                    completion(imageUrl, nil)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(imageUrl, cachedImage)
            }
        }
        task.resume()
        
        return { task.cancel() }
    }
    
    private func cache(data: Data, cacheURL: URL) -> NSImage? {
        guard let inputImage = NSImage(data: data) else {
            return nil
        }
        
        let outputImage = NSImage(size: Metrics.thumbnailSize)
        
        outputImage.lockFocus()
        inputImage.draw(in: NSRect(origin: .zero, size: Metrics.thumbnailSize))
        outputImage.unlockFocus()
        
        do {
            try outputImage.tiffRepresentation?.write(to: cacheURL)
        } catch {
            NSLog("Error saving image to cache: \(error)")
        }
        
        return outputImage
    }
    
}
