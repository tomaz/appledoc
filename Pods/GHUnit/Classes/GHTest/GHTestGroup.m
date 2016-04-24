//
//  GHTestGroup.m
//
//  Created by Gabriel Handford on 1/16/09.
//  Copyright 2009. All rights reserved.
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

#import "GHTestGroup.h"
#import "GHTestCase.h"
#import "GHTestOperation.h"

#import "GHTesting.h"

#import "GHTestGroup+JUnitXML.h"

@interface GHTestGroup ()
- (void)_addTestsFromTestCase:(id)testCase;
- (void)_reset;
@end

@implementation GHTestGroup

@synthesize stats=stats_, parent=parent_, children=children_, delegate=delegate_, interval=interval_, 
status=status_, testCase=testCase_, exception=exception_, options=options_;

- (id)initWithName:(NSString *)name delegate:(id<GHTestDelegate>)delegate {
  if ((self = [super init])) {
    name_ = name;        
    children_ = [NSMutableArray array];
    delegate_ = delegate;
  } 
  return self;
}

- (id)initWithTestCase:(id)testCase delegate:(id<GHTestDelegate>)delegate {
  if ((self = [self initWithName:NSStringFromClass([testCase class]) delegate:delegate])) {
    testCase_ = testCase;
    [self _addTestsFromTestCase:testCase];
  }
  return self;
}

- (id)initWithTestCase:(id)testCase selector:(SEL)selector delegate:(id<GHTestDelegate>)delegate {
  if ((self = [self initWithName:NSStringFromClass([testCase class]) delegate:delegate])) {
    testCase_ = testCase;
    [self addTest:[GHTest testWithTarget:testCase selector:selector]];
  }
  return self;
}

+ (GHTestGroup *)testGroupFromTestCase:(id)testCase delegate:(id<GHTestDelegate>)delegate {
  return [[GHTestGroup alloc] initWithTestCase:testCase delegate:delegate];
}

- (void)dealloc {
  for(id<GHTest> test in children_)
    [test setDelegate:nil];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"%@, %d %0.3f %d/%d (%d failures)", 
                 name_, status_, interval_, stats_.succeedCount, stats_.testCount, stats_.failureCount];
}
  
- (NSString *)name {
  return name_;
}

- (void)_addTestsFromTestCase:(id)testCase {
  NSArray *tests = [[GHTesting sharedInstance] loadTestsFromTarget:testCase];
  [self addTests:tests];
}

- (void)addTestCase:(id)testCase {
  GHTestGroup *testCaseGroup = [[GHTestGroup alloc] initWithTestCase:testCase delegate:self];
  [self addTestGroup:testCaseGroup];
}

- (void)addTestGroup:(GHTestGroup *)testGroup {
  [self addTest:testGroup];
  [testGroup setParent:self];   
}

- (void)addTests:(NSArray *)tests {
  for(GHTest *test in tests)
    [self addTest:test];
}

- (void)addTest:(id<GHTest>)test {
  [test setDelegate:self];  
  stats_.testCount += [test stats].testCount;
  [children_ addObject:test]; 
}

- (NSString *)identifier {
  return name_;
}

// Forward up
- (void)test:(id<GHTest>)test didLog:(NSString *)message source:(id<GHTest>)source {
  [delegate_ test:self didLog:message source:source]; 
}

- (NSArray *)log {
  // Not supported for group (though may be an aggregate of child test logs in the future?)
  return nil;
}

- (void)reset {
  [self _reset];
  for(id<GHTest> test in children_) {
    [test reset];   
  }
  [delegate_ testDidUpdate:self source:self];
}

- (void)_reset {
  status_ = GHTestStatusNone;
  stats_ = GHTestStatsMake(0, 0, 0, stats_.testCount);
  interval_ = 0;
  exception_ = nil; 
}

- (void)_failedTests:(NSMutableArray *)tests testGroup:(id<GHTestGroup>)testGroup {  
  for(id<GHTest> test in [testGroup children]) {
    if ([test conformsToProtocol:@protocol(GHTestGroup)]) 
      [self _failedTests:tests testGroup:(id<GHTestGroup>)test];
    else if (test.status == GHTestStatusErrored) [tests addObject:test];
  }
}

- (NSArray */*of id<GHTest>*/)failedTests {
  NSMutableArray *tests = [NSMutableArray array];
  [self _failedTests:tests testGroup:self];
  return tests;
}

- (void)setException:(NSException *)exception {
  exception_ = exception;
  status_ = GHTestStatusErrored;
  [delegate_ testDidUpdate:self source:self];
}

- (void)cancel {
  if (status_ == GHTestStatusRunning) {
    status_ = GHTestStatusCancelling;
  } else {
    for(id<GHTest> test in children_) {
      stats_.cancelCount++;
      [test cancel];
    }
    status_ = GHTestStatusCancelled;
  }
  [delegate_ testDidUpdate:self source:self];
}

- (void)setDisabled:(BOOL)disabled {
  for(id<GHTest> test in children_)
    [test setDisabled:disabled];
  [delegate_ testDidUpdate:self source:self];
}

- (BOOL)isDisabled {
  for(id<GHTest> test in children_)
    if (![test isDisabled]) return NO;
  return YES;
}

- (void)setHidden:(BOOL)hidden {
  for(id<GHTest> test in children_)
    [test setHidden:hidden];
  [delegate_ testDidUpdate:self source:self];
}

- (BOOL)isHidden {
  for(id<GHTest> test in children_)
    if (![test isHidden]) return NO;
  return YES;
}

- (NSInteger)disabledCount {
  NSInteger disabledCount = 0;
  for(id<GHTest> test in children_) {
    disabledCount += [test disabledCount];
  }
  return disabledCount;
}

- (void)setUpClass {
  if (didSetUpClass_) return;
  didSetUpClass_ = YES;
  // Set up class (if we have a test case)
  @try {    
    if ([testCase_ respondsToSelector:@selector(setUpClass)])     
      [testCase_ setUpClass];
  } @catch(NSException *exception) {
    // If we fail in the setUpClass, then we will cancel all the child tests (below)
    exception_ = exception;
    status_ = GHTestStatusErrored;
    for(id<GHTest> test in children_) {
      if (![test isDisabled]) {
        stats_.failureCount++;
        [test setException:exception_];
      }
    }
  }
}

- (void)tearDownClass {
  // Tear down class (if we were created from a testCase)
  if (status_ != GHTestStatusRunning) return;
  @try {
    if ([testCase_ respondsToSelector:@selector(tearDownClass)])    
      [testCase_ tearDownClass];
  } @catch(NSException *exception) {          
    exception_ = exception;
    status_ = GHTestStatusErrored;
    // We need to reverse any successes in the test run above
    // and set the error on all the child tests
    // TODO(gabe): Don't I need to ignore disabled tests in this loop?
    for(id<GHTest> test in children_) {       
      if ([test status] == GHTestStatusSucceeded) {
        stats_.succeedCount--;
        stats_.failureCount++;
      }
      if (![test isDisabled])
        [test setException:exception_];
    }
  }
}

- (BOOL)hasEnabledChildren {
  return (([children_ count] - [self disabledCount]) <= 0);
}

- (void)_run:(NSOperationQueue *)operationQueue {
  if (status_ == GHTestStatusCancelled || [self hasEnabledChildren]) {
    return;
  }
  
  didSetUpClass_ = NO;
  status_ = GHTestStatusRunning;  
  [delegate_ testDidStart:self source:self];
  
  // Run the tests
  for(id<GHTest> test in children_) {
    // If we are cancelling mark all child tests cancelled (and update stats)
    // If we errored (above), then set the error on the test (and update stats)
    // Otherwise run it
    if (status_ == GHTestStatusCancelling) {
      stats_.cancelCount++;
      [test cancel];
    } else if (status_ == GHTestStatusErrored) {
      stats_.failureCount++;
      [test setException:exception_];
    } else {        
      if (operationQueue) {
        [operationQueue addOperation:[[GHTestOperation alloc] initWithTest:test options:options_]];
      } else {
        if (![test isDisabled])
          [self setUpClass];

        if (status_ == GHTestStatusErrored) break;
        [test run:options_];
      }
    }
  }
  [operationQueue waitUntilAllOperationsAreFinished];
  
  // Tear down class only if we called setUpClass
  if (didSetUpClass_) 
    [self tearDownClass];
  
  if (status_ == GHTestStatusCancelling) {
    status_ = GHTestStatusCancelled;
  } else if (exception_ || stats_.failureCount > 0) {
    status_ = GHTestStatusErrored;
  } else {
    status_ = GHTestStatusSucceeded;
  } 
  [delegate_ testDidEnd:self source:self];
}

- (void)runInOperationQueue:(NSOperationQueue *)operationQueue options:(GHTestOptions)options {
  options_ = options;
  
  NSAssert(!(((options_ & GHTestOptionReraiseExceptions) == GHTestOptionReraiseExceptions) && operationQueue),
           @"Can't run in parallel (through operation queue) and also have re-raise exceptions option set");
  
  [self _reset];
  [self _run:operationQueue];
}

- (BOOL)shouldRunOnMainThread {
  if (self.isDisabled) return NO;
  if ([testCase_ respondsToSelector:@selector(shouldRunOnMainThread)]) 
    return [testCase_ shouldRunOnMainThread];
  return NO;
}

- (void)run:(GHTestOptions)options {  
  options_ = options;
  [self _reset];
  if ([self shouldRunOnMainThread]) {
    [self performSelectorOnMainThread:@selector(_run:) withObject:nil waitUntilDone:YES];
  } else {
    [self _run:nil];
  } 
}

#pragma mark Delegates (GHTestDelegate)

- (void)testDidStart:(id<GHTest>)test source:(id<GHTest>)source {
  [delegate_ testDidStart:self source:source];
  [delegate_ testDidUpdate:self source:self]; 
}

- (void)testDidUpdate:(id<GHTest>)test source:(id<GHTest>)source {
  [delegate_ testDidUpdate:self source:source]; 
  [delegate_ testDidUpdate:self source:self]; 
}

- (void)testDidEnd:(id<GHTest>)test source:(id<GHTest>)source { 
  if (source == test) {
    if ([test interval] >= 0)
      interval_ += [test interval]; 
    stats_.failureCount += [test stats].failureCount;
    stats_.succeedCount += [test stats].succeedCount;
    stats_.cancelCount += [test stats].cancelCount;   
  }
  [delegate_ testDidEnd:self source:source];
  [delegate_ testDidUpdate:self source:self]; 
}

#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
  [coder encodeObject:self.identifier forKey:@"identifier"];
  [coder encodeInteger:self.status forKey:@"status"];
  [coder encodeDouble:self.interval forKey:@"interval"];
}

- (id)initWithCoder:(NSCoder *)coder {
  GHTestGroup *test = [self initWithName:[coder decodeObjectForKey:@"identifier"] delegate:nil];
  test.status = [coder decodeIntegerForKey:@"status"];
  test.interval = [coder decodeDoubleForKey:@"interval"];
  return test;
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
  NSMutableArray *tests = [NSMutableArray arrayWithCapacity:[children_ count]];
  for(id<GHTest> test in children_) {
    id<GHTest> testCopy = [test copyWithZone:zone];
    [tests addObject:testCopy];
  }
  GHTestGroup *testGroup = [[GHTestGroup alloc] initWithName:name_ delegate:nil];
  [testGroup addTests:tests];
  return testGroup;
}

@end

//! @endcond
