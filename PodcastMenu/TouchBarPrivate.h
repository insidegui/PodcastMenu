//
//  TouchBarPrivate.h
//  PodcastMenu
//
//  Created by Guilherme Rambo on 30/09/17.
//  Copyright © 2017 Guilherme Rambo. All rights reserved.
//


#import <AppKit/AppKit.h>

extern void DFRElementSetControlStripPresenceForIdentifier(NSString *__nonnull, BOOL);
extern void DFRSystemModalShowsCloseBoxWhenFrontMost(BOOL);

@interface NSTouchBarItem (Private)

+ (void)addSystemTrayItem:(NSTouchBarItem *__nonnull)item;

@end

@interface NSTouchBar (Private)

+ (void)presentSystemModalFunctionBar:(NSTouchBar *__nonnull)touchBar placement:(long long)placement systemTrayItemIdentifier:(NSString *__nonnull)identifier;
+ (void)dismissSystemModalFunctionBar:(NSTouchBar *__nonnull)touchBar;

@end
