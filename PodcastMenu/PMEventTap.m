//
//  PMEventTap.m
//  PodcastMenu
//
//  Created by Guilherme Rambo on 15/05/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

#import "PMEventTap.h"
#import "PodcastMenu-Swift.h"

@interface PMEventTap ()

@property (nonatomic, strong) MediaKeysCoordinator *coordinator;
@property (nonatomic, copy) void (^mediaKeyEventHandler)(int32_t key, BOOL down);
@property (nonatomic, assign) CFMachPortRef eventPort;

@end

#define CGEventTypeSystemDefined NSSystemDefined

CGEventRef eventTapCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void* context)
{
    PMEventTap *eventTap = (__bridge PMEventTap *)context;
    
    if (![eventTap.coordinator shouldInterceptMediaKeys]) return event;
    
    if (type == kCGEventTapDisabledByTimeout) {
        #ifdef DEBUG
        NSLog(@"[PMEventTap] Tap disabled by timeout, reenabling.");
        #endif
        
        CGEventTapEnable(eventTap.eventPort, true);
        
        return event;
    }
    
    if ((NSEventType)type != CGEventTypeSystemDefined) return event;
    
    NSEvent *theEvent;
    
    @try {
        theEvent = [NSEvent eventWithCGEvent:event];
    } @catch (NSException *e) {
        #ifdef DEBUG
        NSLog(@"[PMEventTap] Received an unknown event. Exception: %@", e);
        #endif
        return event;
    }
    
    if (theEvent.type == NSSystemDefined && theEvent.subtype == 8) {
        NSInteger keyCode = ((theEvent.data1 & 0xFFFF0000) >> 16);
        
        // only fast, play and rewind keys are supported
        if (keyCode != NX_KEYTYPE_FAST && keyCode != NX_KEYTYPE_PLAY && keyCode != NX_KEYTYPE_REWIND) {
            return event;
        }
        
        NSInteger keyFlags = (theEvent.data1 & 0x0000FFFF);
        
        BOOL keyState = (((keyFlags & 0xFF00) >> 8)) == 0xA;
        
        eventTap.mediaKeyEventHandler((int32_t)keyCode, keyState);
        
        if ([eventTap.coordinator shouldPassthroughMediaKeysEvents]) {
            return event;
        } else {
            return NULL;
        }
        return NULL;
    } else {
        return event;
    }
}

@implementation PMEventTap

- (instancetype)initWithMediaKeyEventHandler:(void (^)(int32_t, BOOL))eventHandler
{
    self = [super init];
    
    self.coordinator = [[MediaKeysCoordinator alloc] init];
    self.mediaKeyEventHandler = eventHandler;
    
    return self;
}

- (void)checkButtonPressed:(NSButton *)button
{
    if (!AXIsProcessTrustedWithOptions((CFDictionaryRef)@{(__bridge id)kAXTrustedCheckOptionPrompt: @NO})) {
        return;
    }
    [[NSApplication sharedApplication]abortModal];
    [self startObserving];
}

- (void)openSystemPreferencesButtonPressed:(NSButton *)button
{
    NSString* urlString = @"x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility";
    [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:urlString]];
}
- (void)start
{
    if (@available(macOS 10.14, *)) {
        BOOL accessibilityEnabled = AXIsProcessTrustedWithOptions((CFDictionaryRef)@{(__bridge id)kAXTrustedCheckOptionPrompt: @NO});
        
        if (!accessibilityEnabled) {
            NSAlert *alert = [NSAlert new];
            alert.informativeText = @"Podcast Menu needs to be authorized in order to be able to controlled by your media keys.\n\nYou can do this in System Preferences > Security & Privacy > Privacy > Accessibility. You might need to drag-and-drop Podcast Menu into the list of allowed applications, and make sure the checkbox is on (and then press Check again).";
            alert.messageText = @"Authorization Required";
            
            [alert addButtonWithTitle:@"Check"];
            [alert addButtonWithTitle:@"Quit"];
            [alert addButtonWithTitle:@"Open System Preferences"];
            
            NSButton *checkButton = alert.buttons[0];
            [checkButton setTarget:self];
            checkButton.action = @selector(checkButtonPressed:);
            
            NSButton *systemPreferencesButton = alert.buttons[2];
            [systemPreferencesButton setTarget:self];
            systemPreferencesButton.action = @selector(openSystemPreferencesButtonPressed:);
            
            if ([alert runModal] == NSAlertSecondButtonReturn) {
                [[NSApplication sharedApplication] terminate:nil];
            }
        }
        return;
    }
    
    [self startObserving];
}

- (void)startObserving
{
    dispatch_queue_t eventQueue = dispatch_queue_create("br.com.guilhermerambo.EventTap", NULL);
    dispatch_async(eventQueue, ^{
        CGEventMask mask = CGEventMaskBit(NSSystemDefined);
        self.eventPort = CGEventTapCreate(kCGHIDEventTap, kCGHeadInsertEventTap, 0, mask, eventTapCallback, (__bridge void *)self);
        if (self.eventPort == NULL) {
            NSLog(@"[PMEventTap] Could not create event tap");
            return;
        }
        CFRunLoopSourceRef runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, self.eventPort, 0);
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);
        CGEventTapEnable(self.eventPort, true);
        CFRunLoopRun();
    });
}

@end
