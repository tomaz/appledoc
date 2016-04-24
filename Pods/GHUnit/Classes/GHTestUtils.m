//
//  GHTestUtils.m
//  GHUnitIOS
//
//  Created by John Boiles on 10/22/12.
//  Copyright 2012. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "GHTestUtils.h"
#import <QuartzCore/CoreAnimation.h>

void GHRunForInterval(CFTimeInterval interval) {
  CFTimeInterval checkEveryInterval = 0.01;
  // We use CACurrentMediaTime() instead of [NSDate timeIntervalSinceReferenceDate] here for two reasons
  // 1. One testing strategy for time-dependent code is to mock NSDate methods using swizzling.
  // 2. CACurrentMediaTime() is better for relative timing since it's not subject to network time synchronization.
  CFTimeInterval runUntilTime = CACurrentMediaTime() + interval;
  NSArray *runLoopModes = @[(NSString *)kCFRunLoopDefaultMode, (NSString *)kCFRunLoopCommonModes];
  NSInteger runIndex = 0;
  while (CACurrentMediaTime() < runUntilTime) {
    NSString *mode = [runLoopModes objectAtIndex:(runIndex++ % [runLoopModes count])];
    @autoreleasepool {
      SInt32 runLoopStatus = CFRunLoopRunInMode((__bridge CFStringRef)mode, checkEveryInterval, false);
      if (!mode || (runLoopStatus == kCFRunLoopRunFinished)) {
        // If there were no run loop sources or timers then we should sleep for the interval
        usleep(checkEveryInterval * USEC_PER_SEC);
      }
    }
  }
}

void GHRunUntilTimeoutWhileBlock(CFTimeInterval timeout, BOOL(^whileBlock)()) {
  CFTimeInterval endTime = CACurrentMediaTime() + timeout;
  while (whileBlock() && (CACurrentMediaTime() < endTime)) {
    GHRunForInterval(0.1);
  }
}
