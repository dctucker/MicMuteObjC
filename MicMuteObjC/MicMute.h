//
//  MicMute.h
//  MicMuteObjC
//
//  Created by Douglas Casey Tucker on 2016-02-06.
//  Copyright © 2016 Douglas Casey Tucker. All rights reserved.
//

#ifndef MicMute_h
#define MicMute_h

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioServices.h>

@interface MicMute : NSObject

+(float)volume;
+(void)setVolume:(Float32)newVolume;
+(AudioDeviceID)defaultInputDeviceID;
+(void)toggleMute;

@end

#endif /* MicMute_h */
