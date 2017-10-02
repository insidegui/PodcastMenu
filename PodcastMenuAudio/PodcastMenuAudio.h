//
//  PodcastMenuAudio.h
//  PodcastMenuAudio
//
//  Created by Guilherme Rambo on 02/10/17.
//  Copyright © 2017 Guilherme Rambo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PodcastMenuAudioProtocol.h"

// This object implements the protocol which we have defined. It provides the actual behavior for the service. It is 'exported' by the service to make it available to the process hosting the service over an NSXPCConnection.
@interface PodcastMenuAudio : NSObject <PodcastMenuAudioProtocol>
@end
