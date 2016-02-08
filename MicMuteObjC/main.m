//
//  main.m
//  MicMuteObjC
//
//  Created by Douglas Casey Tucker on 2016-02-06.
//  Copyright © 2016 Douglas Casey Tucker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MicMute.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        // float vol = [MicMute volume];
        // NSLog(@"Hello, World! %.2f", vol);
        // [MicMute setVolume:0.5];
        UInt32 muted = [MicMute toggleMute];
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
