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

+(float)volume
{
    Float32			inputVolume;
    
    UInt32 propertySize = 0;
    OSStatus status = noErr;
    AudioObjectPropertyAddress propertyAOPA;
    propertyAOPA.mElement = kAudioObjectPropertyElementMaster;
    propertyAOPA.mSelector = kAudioHardwareServiceDeviceProperty_VirtualMasterVolume;
    propertyAOPA.mScope = kAudioDevicePropertyScopeInput;
    
    AudioDeviceID inputDeviceID = [MicMute defaultInputDeviceID];
    
    if (inputDeviceID == kAudioObjectUnknown)
    {
        NSLog(@"Unknown device");
        return 0.0;
    }
    
    if (!AudioHardwareServiceHasProperty(inputDeviceID, &propertyAOPA))
    {
        NSLog(@"No volume returned for device 0x%0x", inputDeviceID);
        return 0.0;
    }
    
    propertySize = sizeof(Float32);
    
    status = AudioHardwareServiceGetPropertyData(inputDeviceID, &propertyAOPA, 0, NULL, &propertySize, &inputVolume);
    
    if (status)
    {
        NSLog(@"No volume returned for device 0x%0x", inputDeviceID);
        return 0.0;
    }
    
    if (inputVolume < 0.0 || inputVolume > 1.0) return 0.0;
    
    return inputVolume;
}

// setting system volume - mutes if under threshhold
+(void)setVolume:(Float32)newVolume
{
    if (newVolume < 0.0 || newVolume > 1.0)
    {
        NSLog(@"Requested volume out of range (%.2f)", newVolume);
        return;
        
    }
    
    // get input device device
    UInt32 propertySize = 0;
    OSStatus status = noErr;
    AudioObjectPropertyAddress propertyAOPA;
    propertyAOPA.mElement = kAudioObjectPropertyElementMaster;
    propertyAOPA.mScope = kAudioDevicePropertyScopeInput;
    
    if (newVolume < 0.001)
    {
        NSLog(@"Requested mute");
        propertyAOPA.mSelector = kAudioDevicePropertyMute;
        
    }
    else
    {
        NSLog(@"Requested volume %.2f", newVolume);
        propertyAOPA.mSelector = kAudioHardwareServiceDeviceProperty_VirtualMasterVolume;
    }
    
    AudioDeviceID inputDeviceID = [MicMute defaultInputDeviceID];
    
    if (inputDeviceID == kAudioObjectUnknown)
    {
        NSLog(@"Unknown device");
        return;
    }
    
    if (!AudioHardwareServiceHasProperty(inputDeviceID, &propertyAOPA))
    {
        NSLog(@"Device 0x%0x does not support volume control", inputDeviceID);
        return;
    }
    
    Boolean canSetVolume = NO;
    
    status = AudioHardwareServiceIsPropertySettable(inputDeviceID, &propertyAOPA, &canSetVolume);
    
    if (status || canSetVolume == NO)
    {
        NSLog(@"Device 0x%0x does not support volume control", inputDeviceID);
        return;
    }
    
    if (propertyAOPA.mSelector == kAudioDevicePropertyMute)
    {
        propertySize = sizeof(UInt32);
        UInt32 mute = 1;
        status = AudioHardwareServiceSetPropertyData(inputDeviceID, &propertyAOPA, 0, NULL, propertySize, &mute);
    }
    else
    {
        propertySize = sizeof(Float32);
        
        status = AudioHardwareServiceSetPropertyData(inputDeviceID, &propertyAOPA, 0, NULL, propertySize, &newVolume);
        
        if (status)
        {
            NSLog(@"Unable to set volume for device 0x%0x", inputDeviceID);
        }
        
        // make sure we're not muted
        propertyAOPA.mSelector = kAudioDevicePropertyMute;
        propertySize = sizeof(UInt32);
        UInt32 mute = 0;
        
        if (!AudioHardwareServiceHasProperty(inputDeviceID, &propertyAOPA))
        {
            NSLog(@"Device 0x%0x does not support muting", inputDeviceID);
            return;
        }
        
        Boolean canSetMute = NO;
        
        status = AudioHardwareServiceIsPropertySettable(inputDeviceID, &propertyAOPA, &canSetMute);
        
        if (status || !canSetMute)
        {
            NSLog(@"Device 0x%0x does not support muting", inputDeviceID);
            return;
        }
        
        status = AudioHardwareServiceSetPropertyData(inputDeviceID, &propertyAOPA, 0, NULL, propertySize, &mute);
    }
    
    if (status)
    {
        NSLog(@"Unable to set volume for device 0x%0x", inputDeviceID);
    }
    
}

+(void)toggleMute
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
        return;
    }

    propertySize = sizeof(UInt32);
    UInt32 mute = 0;

    status = AudioHardwareServiceGetPropertyData(inputDeviceID, &propertyAOPA, 0, NULL, &propertySize, &mute);
    mute = mute ? 0 : 1;
    status = AudioHardwareServiceSetPropertyData(inputDeviceID, &propertyAOPA, 0, NULL, propertySize, &mute);
    if( mute )
    {
        printf("Muted\n");
    }
    else
    {
        printf("Un-muted\n");
    }
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
