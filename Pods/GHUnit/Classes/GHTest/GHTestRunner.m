//
//  GHTestRunner.m
//
//  Copyright 2008 Gabriel Handford
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

//! @cond DEV

//
// Portions of this file fall under the following license, marked with:
// GTM_BEGIN : GTM_END
//
//  Copyright 2008 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not
//  use this file except in compliance with the License.  You may obtain a copy
//  of the License at
// 
//  http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
//  License for the specific language governing permissions and limitations under
//  the License.
//

#import "GHTestRunner.h"
#import "GHTestSuite.h"
#import "GHTesting.h"

#import <stdio.h>

@interface GHTestRunner ()
- (void)_notifyStart;
- (void)_notifyCancelled;
- (void)_notifyFinished;
- (void)_log:(NSString *)message;
@end

@implementation GHTestRunner

@synthesize test=test_, options=options_, delegate=delegate_, running=running_, cancelling=cancelling_,
operationQueue=operationQueue_;

- (id)initWithTest:(id<GHTest>)test {
  if ((self = [self init])) {
    test_ = test;
    test_.delegate = self;
  }
  return self;
}


+ (GHTestRunner *)runnerForAllTests {
  GHTestSuite *suite = [GHTestSuite allTests];
  return [self runnerForSuite:suite];
}

+ (GHTestRunner *)runnerForSuite:(GHTestSuite *)suite { 
  GHTestRunner *runner = [[GHTestRunner alloc] initWithTest:suite];
  return runner;
}

+ (GHTestRunner *)runnerForTestClassName:(NSString *)testClassName methodName:(NSString *)methodName {
  return [self runnerForSuite:[GHTestSuite suiteWithTestCaseClass:NSClassFromString(testClassName) 
                                                           method:NSSelectorFromString(methodName)]];
}

+ (GHTestRunner *)runnerFromEnv {
  GHTestSuite *suite = [GHTestSuite suiteFromEnv];
  GHTestRunner *runner = [GHTestRunner runnerForSuite:suite];
  if (getenv("GHUNIT_RERAISE")) runner.options = GHTestOptionReraiseExceptions;
  return runner;
} 

+ (int)run {
  GHTestRunner *testRunner = [GHTestRunner runnerFromEnv];
  [testRunner runTests];
  return (int)testRunner.stats.failureCount; 
}

- (void)setInParallel:(BOOL)inParallel {
  if (inParallel) {
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    operationQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    self.operationQueue = operationQueue;
  } else {
    self.operationQueue = nil;
  }
}  

- (BOOL)isInParallel {
  return (!!self.operationQueue);
}

- (int)runTests {
  if (cancelling_ || running_) return -1;
  
  running_ = YES;
  startInterval_ = [NSDate timeIntervalSinceReferenceDate];
  [self _notifyStart];
  
  if (operationQueue_ && [test_ respondsToSelector:@selector(runInOperationQueue:options:)]) {
    [(id)test_ runInOperationQueue:operationQueue_ options:options_];
  } else {
    [test_ run:options_];
  }
  return (int)self.stats.failureCount;
}

- (NSTimeInterval)interval {
  return ([NSDate timeIntervalSinceReferenceDate] - startInterval_);
}

- (void)cancel {
  if (cancelling_) return;
  cancelling_ = YES;
  [operationQueue_ cancelAllOperations];
  [test_ cancel];
}

- (void)runInBackground {
  [NSThread detachNewThreadSelector:@selector(_runInBackground) toTarget:self withObject:nil];
}

- (void)_runInBackground {
  @autoreleasepool {
    [self runTests];
  }
}

- (GHTestStats)stats {
  return [test_ stats];
}
    
- (void)log:(NSString *)message {
  fputs([message UTF8String], stderr);
  fflush(stderr);
}

- (void)_log:(NSString *)message {
  fputs([message UTF8String], stdout);
  fputs("\n", stdout);
  fflush(stdout);
  
  dispatch_async(dispatch_get_main_queue(), ^{
    if ([delegate_ respondsToSelector:@selector(testRunner:didLog:)])
      [delegate_ testRunner:self didLog:message];
  });  
}

#pragma mark Delegates (GHTest)

- (void)testDidStart:(id<GHTest>)test source:(id<GHTest>)source {
  if (![source conformsToProtocol:@protocol(GHTestGroup)]) {
    [self log:[NSString stringWithFormat:@"Starting %@\n", [source identifier]]];
  }
  
  dispatch_async(dispatch_get_main_queue(), ^{
    if ([delegate_ respondsToSelector:@selector(testRunner:didStartTest:)])
    [delegate_ testRunner:self didStartTest:source]; 
  });
}

- (void)testDidUpdate:(id<GHTest>)test source:(id<GHTest>)source {  
  dispatch_async(dispatch_get_main_queue(), ^{
    if ([delegate_ respondsToSelector:@selector(testRunner:didUpdateTest:)])
      [delegate_ testRunner:self didUpdateTest:source];  
  });
}

- (void)testDidEnd:(id<GHTest>)test source:(id<GHTest>)source { 
  
  if ([source status] != GHTestStatusCancelled) {
    if (![source conformsToProtocol:@protocol(GHTestGroup)]) {      
      NSString *message = [NSString stringWithFormat:@" %@ (%0.3fs)\n\n", 
                           ([source stats].failureCount > 0 ? @"FAIL" : @"OK"), [source interval]]; 
      [self log:message];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
      if ([delegate_ respondsToSelector:@selector(testRunner:didEndTest:)])
        [delegate_ testRunner:self didEndTest:source];
    });

  } else {
    [self log:@"Cancelled\n"];
  }
    
  if (cancelling_) {
    [self _notifyCancelled];
  } else if (test_ == source && [source status] != GHTestStatusCancelled) {
    // If the test associated with this runner ended then notify
    [self _notifyFinished];
  } 
}

- (void)test:(id<GHTest>)test didLog:(NSString *)message source:(id<GHTest>)source {
  [self _log:[NSString stringWithFormat:@"%@: %@", source, message]];
  dispatch_async(dispatch_get_main_queue(), ^{
    if ([delegate_ respondsToSelector:@selector(testRunner:test:didLog:)])
      [delegate_ testRunner:self test:source didLog:message];
  });
}

#pragma mark Notifications (Private)

- (void)_notifyStart {  
  NSString *message = [NSString stringWithFormat:@"Test Suite '%@' started.\n", [test_ name]];
  [self log:message];
  
  dispatch_async(dispatch_get_main_queue(), ^{
    if ([delegate_ respondsToSelector:@selector(testRunnerDidStart:)])
      [delegate_ testRunnerDidStart:self];
  });
}

- (void)_notifyCancelled {
  NSString *message = [NSString stringWithFormat:@"Test Suite '%@' cancelled.\n", [test_ name]];
  [self log:message];
  
  cancelling_ = NO;
  running_ = NO;
  
  dispatch_async(dispatch_get_main_queue(), ^{
    if ([delegate_ respondsToSelector:@selector(testRunnerDidCancel:)])
      [delegate_ testRunnerDidCancel:self];
  });
}

- (void)_notifyFinished {
  NSString *message = [NSString stringWithFormat:@"Test Suite '%@' finished.\n"
                       "Executed %d of %d tests, with %d failures in %0.3f seconds (%d disabled).\n",
                       [test_ name], 
                       ([test_ stats].succeedCount + [test_ stats].failureCount), 
                       [test_ stats].testCount,
                       [test_ stats].failureCount, 
                       [test_ interval],
                       [test_ disabledCount]];
  [self log:message];
  
  if ([test_ isKindOfClass:[GHTestGroup class]]) {
    GHTestGroup *testGroup = (GHTestGroup *)test_;
    [self log:@"\nFailed tests:\n"];
    for(id<GHTest> test in [testGroup failedTests]) {
      [self log:[NSString stringWithFormat:@"\t%@\n", [test identifier]]];
    }
    [self log:@"\n"];
  }
  
  if ([test_ isKindOfClass:[GHTestSuite class]]) {
    GHTestSuite *testSuite = (GHTestSuite *)test_;

    // Log JUnit XML if environment variable is set
    if (getenv("WRITE_JUNIT_XML")) {
      NSError *error = nil;

      NSString *resultsDir;
      
      char *resultsDirStr = getenv("JUNIT_XML_DIR");
      if (resultsDirStr) {
        resultsDir = [NSString stringWithUTF8String:resultsDirStr];
      } else {
        NSString *tmpDir = NSTemporaryDirectory();
        resultsDir = [tmpDir stringByAppendingPathComponent:@"test-results"];
      }      

      [self log:[NSString stringWithFormat:@"Writing JUnit XML to:%@.\n", resultsDir]];
      
      if (![testSuite writeJUnitXMLToDirectory:resultsDir error:&error]) {
        [self log:[NSString stringWithFormat:@"Error writing JUnit XML: %@\n", [error localizedDescription]]];
      } else {
        [self log:@"Wrote JUnit XML successfully.\n"];
      }
    }
  }

  cancelling_ = NO;
  running_ = NO;

  dispatch_async(dispatch_get_main_queue(), ^{
    if ([delegate_ respondsToSelector:@selector(testRunnerDidEnd:)])
      [delegate_ testRunnerDidEnd:self];   
  });
}

@end

//! @endcond
