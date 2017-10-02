//
//  PodcastMenuAudioProtocol.h
//  PodcastMenuAudio
//
//  Created by Guilherme Rambo on 02/10/17.
//  Copyright © 2017 Guilherme Rambo. All rights reserved.
//

#import <Foundation/Foundation.h>

// The protocol that this service will vend as its API. This header file will also need to be visible to the process hosting the service.
@protocol PodcastMenuAudioProtocol

- (void)beginPlayingMediaAtURL:(NSURL *__nonnull)url
                 seekingToTime:(NSTimeInterval)time
           useURLTimeIfPresent:(BOOL)shouldUseURLTime;

- (void)pause;

- (void)seekForwardWithTime:(NSTimeInterval)time;
- (void)seekBackwardWithTime:(NSTimeInterval)time;

- (void)setPlaybackRate:(float)rate;
    
@end
