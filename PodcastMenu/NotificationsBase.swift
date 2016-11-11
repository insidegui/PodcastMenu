//
//  NotificationsBase.swift
//  PodcastMenu
//
//  Created by Guilherme Rambo on 12/05/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation

protocol NotificationsBase: RawRepresentable {
    var rawValue: Notification.Name { get }
    
    func post()
    func subscribe(block: @escaping (Notification) -> ()) -> NSObjectProtocol
    func subscribe(block: @escaping () -> ())
    func unsubscribe(observer: NSObjectProtocol)
}

extension NotificationsBase {
    func post() {
        NotificationCenter.default.post(name: rawValue, object: nil)
    }
    
    func subscribe(block: @escaping (Notification) -> ()) -> NSObjectProtocol {
        let name = rawValue
        return NotificationCenter.default.addObserver(forName: name, object: nil, queue: OperationQueue.main, using: block)
    }
    
    func subscribe(block: @escaping () -> ()) {
        _ = subscribe { (note: Notification) -> Void in
            block()
        }
    }
    
    func unsubscribe(observer: NSObjectProtocol) {
        let name = rawValue
        NotificationCenter.default.removeObserver(observer, name: name, object: nil)
    }
}
