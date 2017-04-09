//
//  NSImage+CGImage.m
//  PodcastMenu
//
//  Created by Guilherme Rambo on 21/09/15.
//  Copyright © 2015 Guilherme Rambo. All rights reserved.
//

#import "NSImage+CGImage.h"

@implementation NSImage (CGImage)

- (CGImageRef)imageRefAtIndex:(int)index
{
    CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)[self TIFFRepresentation], NULL);
    
    return CGImageSourceCreateImageAtIndex(source, index, NULL);
}

- (CGImageRef)CGImage
{
    return [self imageRefAtIndex:0];
}

- (CGImageRef)CGImageForCurrentScale
{
    int idx = ([NSScreen mainScreen].backingScaleFactor > 1) ? 1 : 0;
    
    return [self imageRefAtIndex:idx];
}

@end
