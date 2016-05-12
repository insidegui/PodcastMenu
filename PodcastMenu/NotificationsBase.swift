//
//  NotificationsBase.swift
//  PodcastMenu
//
//  Created by Guilherme Rambo on 12/05/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation

protocol NotificationsBase: RawRepresentable {
    func post()
    func subscribe(block: (notification: NSNotification) -> ()) -> NSObjectProtocol
    func unsubscribe(observer: NSObjectProtocol)
}

extension NotificationsBase {
    func post() {
        NSNotificationCenter.defaultCenter().postNotificationName(rawValue as! String, object: nil)
    }
    
    func subscribe(block: (notification: NSNotification) -> ()) -> NSObjectProtocol {
        let name = rawValue as! String
        return NSNotificationCenter.defaultCenter().addObserverForName(name, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: block)
    }
    
    func unsubscribe(observer: NSObjectProtocol) {
        let name = rawValue as! String
        NSNotificationCenter.defaultCenter().removeObserver(observer, name: name, object: nil)
    }
}