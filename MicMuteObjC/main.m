//
//  main.m
//  MicMuteObjC
//
//  Created by Douglas Casey Tucker on 2016-02-06.
//  Copyright © 2016 Douglas Casey Tucker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MicMute.h"

#import <objc/runtime.h>


#pragma mark - Swizzle NSBundle

NSString *fakeBundleIdentifier = nil;

@implementation NSBundle(swizle)

// Overriding bundleIdentifier works, but overriding NSUserNotificationAlertStyle does not work.

- (NSString *)__bundleIdentifier
{
    if (self == [NSBundle mainBundle]) {
        return fakeBundleIdentifier ? fakeBundleIdentifier : @"com.apple.audio.AudioMIDISetup";
    } else {
        return [self __bundleIdentifier];
    }
}

@end

BOOL installNSBundleHook()
{
    Class class = objc_getClass("NSBundle");
    if (class) {
        method_exchangeImplementations(class_getInstanceMethod(class, @selector(bundleIdentifier)),
                                       class_getInstanceMethod(class, @selector(__bundleIdentifier)));
        return YES;
    }
    return NO;
}


#pragma mark - NotificationCenterDelegate

@interface NotificationCenterDelegate : NSObject<NSUserNotificationCenterDelegate>

@property (nonatomic, assign) BOOL keepRunning;

@end

@implementation NotificationCenterDelegate

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didDeliverNotification:(NSUserNotification *)notification
{
    self.keepRunning = NO;
}

@end

#pragma mark -

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        UInt32 muted = [MicMute toggleMute];
        
        if (installNSBundleHook())
        {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            fakeBundleIdentifier = [defaults stringForKey:@"identifier"];
            
            NSUserNotificationCenter *nc = [NSUserNotificationCenter defaultUserNotificationCenter];
            NotificationCenterDelegate *ncDelegate = [[NotificationCenterDelegate alloc]init];
            ncDelegate.keepRunning = YES;
            nc.delegate = ncDelegate;
            
            NSUserNotification *note = [[NSUserNotification alloc] init];
            note.title = @"Microphone";
            note.subtitle = muted ? @"Muted" : @"Un-muted";
            // note.informativeText = @"informativeText";
            
            [nc scheduleNotification:note];
        }
        
        if( muted == 0 )
        {
            printf("Un-muted\n");
        }
        else if( muted == 1 )
        {
            printf("Muted\n");
        }
        else
        {
            return 1;
        }
    }
    return 0;
}
