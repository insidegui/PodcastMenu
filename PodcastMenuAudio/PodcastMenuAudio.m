//
//  PodcastMenuAudio.m
//  PodcastMenuAudio
//
//  Created by Guilherme Rambo on 02/10/17.
//  Copyright © 2017 Guilherme Rambo. All rights reserved.
//

#import "PodcastMenuAudio.h"

#define kDefaultTimeScale 9000

NSString * const kTimeParameterName = @"t";
NSString * const kErrorDomain = @"br.com.guilhermerambo.PodcastMenuAudio";

@import AVFoundation;

@interface PodcastMenuAudio ()

@property (nonatomic, strong) AVPlayer *player;

@end

@implementation PodcastMenuAudio

- (void)beginPlayingMediaAtURL:(NSURL *)url
                 seekingToTime:(NSTimeInterval)time
           useURLTimeIfPresent:(BOOL)shouldUseURLTime
{
    NSTimeInterval effectiveStartTime = time;
    
    if (shouldUseURLTime) {
        NSError *parsingError;
        NSTimeInterval timeFromURL = [self _timeFromURL:url error:&parsingError];
        if (parsingError) {
#ifdef DEBUG
            NSLog(@"Error parsing time from URL: %@", parsingError);
#endif
        } else {
            effectiveStartTime = timeFromURL;
        }
    }
    
#ifdef DEBUG
    NSLog(@"Media start time: %.2f", effectiveStartTime);
#endif
    
    self.player = [AVPlayer playerWithURL:url];
    [self.player play];
    [self.player seekToTime:CMTimeMakeWithSeconds(effectiveStartTime, kDefaultTimeScale)];
}

- (void)pause
{
    [self.player pause];
}

- (void)seekForwardWithTime:(NSTimeInterval)time
{
    CMTime increment = CMTimeMakeWithSeconds(time, kDefaultTimeScale);
    CMTime newTime = CMTimeAdd(self.player.currentTime, increment);
    
    if (!CMTIME_IS_VALID(newTime)) {
#ifdef DEBUG
        NSLog(@"%@ resulted in an invalid time!", NSStringFromSelector(_cmd));
#endif
        return;
    }
    
    [self.player seekToTime:newTime];
}

- (void)seekBackwardWithTime:(NSTimeInterval)time
{
    CMTime decrement = CMTimeMakeWithSeconds(time, kDefaultTimeScale);
    CMTime newTime = CMTimeSubtract(self.player.currentTime, decrement);
    
    if (!CMTIME_IS_VALID(newTime)) {
#ifdef DEBUG
        NSLog(@"%@ resulted in an invalid time!", NSStringFromSelector(_cmd));
#endif
        return;
    }
    
    [self.player seekToTime:newTime];
}

- (void)setPlaybackRate:(float)rate
{
    self.player.rate = rate;
}

#pragma mark Private

- (NSTimeInterval)_timeFromURL:(NSURL *)url error:(NSError **)outError
{
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    
    if (!components.fragment) {
        *outError = [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"No usable fragment"}];
        return 0;
    }
    
    NSURL *extractionURL = [NSURL URLWithString:[NSString stringWithFormat:@"podcastmenuapp://t?%@", components.fragment]];
    NSURLComponents *extractionComponents = [NSURLComponents componentsWithURL:extractionURL resolvingAgainstBaseURL:NO];
    
    __block NSTimeInterval outTime = 0;
    [extractionComponents.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem *item, NSUInteger idx, BOOL *stop) {
        if ([item.name isEqualToString:kTimeParameterName]) {
            outTime = [item.value doubleValue];
            *stop = YES;
        }
    }];
    
    return outTime;
}

@end

