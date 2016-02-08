//
//  MicMute.m
//  MicMuteObjC
//
//  Created by Douglas Casey Tucker on 2016-02-06.
//  Copyright © 2016 Douglas Casey Tucker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioServices.h>

#import "MicMute.h"

// getting system volume

@implementation MicMute

+(UInt32)toggleMute
{
    // get input device device
    UInt32 propertySize = 0;
    OSStatus status = noErr;
    AudioObjectPropertyAddress propertyAOPA;
    propertyAOPA.mElement = kAudioObjectPropertyElementMaster;
    propertyAOPA.mScope = kAudioDevicePropertyScopeInput;
    propertyAOPA.mSelector = kAudioDevicePropertyMute;
    AudioDeviceID inputDeviceID = [MicMute defaultInputDeviceID];

    if (inputDeviceID == kAudioObjectUnknown)
    {
        NSLog(@"Unknown device");
        return -1;
    }

    propertySize = sizeof(UInt32);
    UInt32 mute = 0;

    status = AudioHardwareServiceGetPropertyData(inputDeviceID, &propertyAOPA, 0, NULL, &propertySize, &mute);
    mute = mute ? 0 : 1;
    status = AudioHardwareServiceSetPropertyData(inputDeviceID, &propertyAOPA, 0, NULL, propertySize, &mute);
    return mute;
}

+(AudioDeviceID)defaultInputDeviceID
{
    AudioDeviceID	inputDeviceID = kAudioObjectUnknown;
    
    // get input device device
    UInt32 propertySize = 0;
    OSStatus status = noErr;
    AudioObjectPropertyAddress propertyAOPA;
    propertyAOPA.mScope = kAudioObjectPropertyScopeGlobal;
    propertyAOPA.mElement = kAudioObjectPropertyElementMaster;
    propertyAOPA.mSelector = kAudioHardwarePropertyDefaultInputDevice;
    
    if (!AudioHardwareServiceHasProperty(kAudioObjectSystemObject, &propertyAOPA))
    {
        NSLog(@"Cannot find default input device!");
        return inputDeviceID;
    }
    
    propertySize = sizeof(AudioDeviceID);
    
    status = AudioHardwareServiceGetPropertyData(kAudioObjectSystemObject, &propertyAOPA, 0, NULL, &propertySize, &inputDeviceID);
    
    if(status) 
    {
        NSLog(@"Cannot find default input device!");
    }
    return inputDeviceID;
}

@end
