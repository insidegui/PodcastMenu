//
//  PMEventTap.h
//  PodcastMenu
//
//  Created by Guilherme Rambo on 15/05/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

@import Cocoa;

@interface PMEventTap : NSObject

- (_Nonnull instancetype)initWithMediaKeyEventHandler:(void (^_Nonnull)(int32_t key, BOOL down))eventHandler;

- (void)start;

@end
