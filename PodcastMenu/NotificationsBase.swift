//
//  NotificationsBase.swift
//  PodcastMenu
//
//  Created by Guilherme Rambo on 12/05/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation

protocol NotificationsBase: RawRepresentable {
    var rawValue: String { get }
    
    func post()
    func subscribe(block: (notification: NSNotification) -> ()) -> NSObjectProtocol
    func subscribe(block: () -> ())
    func unsubscribe(observer: NSObjectProtocol)
}

extension NotificationsBase {
    func post() {
        NSNotificationCenter.defaultCenter().postNotificationName(rawValue, object: nil)
    }
    
    func subscribe(block: (notification: NSNotification) -> ()) -> NSObjectProtocol {
        let name = rawValue
        return NSNotificationCenter.defaultCenter().addObserverForName(name, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: block)
    }
    
    func subscribe(block: () -> ()) {
        subscribe { (note: NSNotification) -> Void in
            block()
        }
    }
    
    func unsubscribe(observer: NSObjectProtocol) {
        let name = rawValue
        NSNotificationCenter.defaultCenter().removeObserver(observer, name: name, object: nil)
    }
}