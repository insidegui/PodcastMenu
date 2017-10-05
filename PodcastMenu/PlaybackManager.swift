//
//  PlaybackManager.swift
//  PodcastMenu
//
//  Created by Guilherme Rambo on 05/10/17.
//  Copyright © 2017 Guilherme Rambo. All rights reserved.
//

import Foundation

final class PlaybackManager: NSObject {
    
    static let shared: PlaybackManager = PlaybackManager()
    
    private lazy var serviceConnection: NSXPCConnection = {
        let connection  = NSXPCConnection(serviceName: "br.com.guilhermerambo.PodcastMenuAudio")
        
        defer { connection.resume() }
        
        connection.remoteObjectInterface = NSXPCInterface(with: PodcastMenuAudioProtocol.self)
        
        return connection
    }()
    
    private lazy var audioController: PodcastMenuAudioProtocol = {
        return self.serviceConnection.remoteObjectProxy as! PodcastMenuAudioProtocol
    }()
    
    func play(from url: URL) {
        audioController.beginPlayingMedia(at: url, seekingToTime: 0, useURLTimeIfPresent: true)
    }
    
    func pause() {
        audioController.setPlaybackRate(0)
    }
    
}
