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
        [MicMute toggleMute];
    }
    return 0;
}
