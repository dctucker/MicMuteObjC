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

+(AudioDeviceID)defaultInputDeviceID;
+(UInt32)toggleMute;

@end

#endif /* MicMute_h */
