//
//  GHTest.m
//  GHUnit
//
//  Created by Gabriel Handford on 1/18/09.
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

#import "GHTest.h"
#import "GHTest+JUnitXML.h"

#import "GHTesting.h"
#import "GHTestCase.h"

@interface GHTest ()
- (void)_setLogWriter:(id<GHTestCaseLogWriter>)logWriter;
@end

NSString* NSStringFromGHTestStatus(GHTestStatus status) {
  switch(status) {
    case GHTestStatusNone: return NSLocalizedString(@"Waiting", nil);
    case GHTestStatusRunning: return NSLocalizedString(@"Running", nil);
    case GHTestStatusCancelling: return NSLocalizedString(@"Cancelling", nil);
    case GHTestStatusSucceeded: return NSLocalizedString(@"Succeeded", nil); 
    case GHTestStatusErrored: return NSLocalizedString(@"Errored", nil);
    case GHTestStatusCancelled: return NSLocalizedString(@"Cancelled", nil);
      
    default: return NSLocalizedString(@"Unknown", nil);
  }
}

GHTestStats GHTestStatsMake(NSInteger succeedCount, NSInteger failureCount, NSInteger cancelCount, NSInteger testCount) {
  GHTestStats stats;
  stats.succeedCount = succeedCount;
  stats.failureCount = failureCount; 
  stats.cancelCount = cancelCount;  
  stats.testCount = testCount;
  return stats;
}

const GHTestStats GHTestStatsEmpty = {0, 0, 0, 0};

NSString *NSStringFromGHTestStats(GHTestStats stats) {
  return [NSString stringWithFormat:@"%d/%d/%d/%d", stats.succeedCount, stats.failureCount, 
          stats.cancelCount, stats.testCount]; 
}

BOOL GHTestStatusIsRunning(GHTestStatus status) {
  return (status == GHTestStatusRunning || status == GHTestStatusCancelling);
}

BOOL GHTestStatusEnded(GHTestStatus status) {
  return (status == GHTestStatusSucceeded 
          || status == GHTestStatusErrored
          || status == GHTestStatusCancelled);
}

@implementation GHTest

@synthesize delegate=delegate_, target=target_, selector=selector_, name=name_, interval=interval_, 
exception=exception_, status=status_, log=log_, identifier=identifier_, disabled=disabled_, hidden=hidden_;

- (id)initWithIdentifier:(NSString *)identifier name:(NSString *)name {
  if ((self = [self init])) {
    identifier_ = identifier;
    name_ = name;
    interval_ = -1;
    status_ = GHTestStatusNone;
  }
  return self;
}

- (id)initWithTarget:(id)target selector:(SEL)selector {
  NSString *name = NSStringFromSelector(selector);
  NSString *identifier = [NSString stringWithFormat:@"%@/%@", NSStringFromClass([target class]), name];
  if ((self = [self initWithIdentifier:identifier name:name])) {
    target_ = target;
    selector_ = selector;
  }
  return self;  
}

+ (id)testWithTarget:(id)target selector:(SEL)selector {
  return [[self alloc] initWithTarget:target selector:selector];
}


- (BOOL)isEqual:(id)test {
  return ((test == self) || 
          ([test conformsToProtocol:@protocol(GHTest)] && 
           [self.identifier isEqual:[test identifier]]));
}

- (NSString *)description {
  return [NSString stringWithFormat:@"%@ %@", self.identifier, [super description]];
}

- (GHTestStats)stats {
  switch(status_) {
    case GHTestStatusSucceeded: return GHTestStatsMake(1, 0, 0, 1);
    case GHTestStatusErrored: return GHTestStatsMake(0, 1, 0, 1);
    case GHTestStatusCancelled: return GHTestStatsMake(0, 0, 1, 1);
    default:
      return GHTestStatsMake(0, 0, 0, 1);
  }
}

- (void)reset {
  status_ = GHTestStatusNone;
  interval_ = 0;
  exception_ = nil; 
  [delegate_ testDidUpdate:self source:self];
}

- (void)cancel {
  if (status_ == GHTestStatusRunning) {
    status_ = GHTestStatusCancelling;
    // TODO(gabe): Call cancel on target if available?    
  } else {
    status_ = GHTestStatusCancelled;
  }
  [delegate_ testDidUpdate:self source:self];
}

- (void)setDisabled:(BOOL)disabled {
  disabled_ = disabled;
  [delegate_ testDidUpdate:self source:self];
}

- (void)setHidden:(BOOL)hidden {
  hidden_ = hidden;
  [delegate_ testDidUpdate:self source:self];
}

- (NSInteger)disabledCount {
  return (disabled_ || hidden_ ? 1 : 0);
}

- (void)setException:(NSException *)exception {
  exception_ = exception;
  status_ = GHTestStatusErrored;
  [delegate_ testDidUpdate:self source:self];
}

- (void)setUpClass {
  // Set up class
  @try {    
    if ([target_ respondsToSelector:@selector(setUpClass)]) {
      [target_ setUpClass];
    }
  } @catch(NSException *exception) {
    // If we fail in the setUpClass, then we will cancel all the child tests (below)
    exception_ = exception;
    status_ = GHTestStatusErrored;
  }
}

- (void)tearDownClass {
  // Tear down class
  @try {
    if ([target_ respondsToSelector:@selector(tearDownClass)])    
      [target_ tearDownClass];
  } @catch(NSException *exception) {          
    exception_ = exception;
    status_ = GHTestStatusErrored;
  }
}

- (void)run:(GHTestOptions)options {
  if (status_ == GHTestStatusCancelled || disabled_ || hidden_) return;
  
  if ((options & GHTestOptionForceSetUpTearDownClass) == GHTestOptionForceSetUpTearDownClass) {
    [self setUpClass];
    if (status_ == GHTestStatusErrored) return; 
  }
  
  status_ = GHTestStatusRunning;
  
  [delegate_ testDidStart:self source:self];
  
  [self _setLogWriter:self];

  BOOL reraiseExceptions = ((options & GHTestOptionReraiseExceptions) == GHTestOptionReraiseExceptions);
  NSException *exception = nil;
  [GHTesting runTestWithTarget:target_ selector:selector_ exception:&exception interval:&interval_ reraiseExceptions:reraiseExceptions];
  exception_ = exception;
  
  [self _setLogWriter:nil];

  if (exception_) {
    status_ = GHTestStatusErrored;
  }

  if (status_== GHTestStatusCancelling) {
    status_ = GHTestStatusCancelled;
  } else if (status_ == GHTestStatusRunning) {
    status_ = GHTestStatusSucceeded;
  }
  
  if ((options & GHTestOptionForceSetUpTearDownClass) == GHTestOptionForceSetUpTearDownClass)
    [self tearDownClass];
  
  [delegate_ testDidEnd:self source:self];
}

- (void)log:(NSString *)message testCase:(id)testCase {
  if (!log_) log_ = [NSMutableArray array];
  [log_ addObject:message];
  [delegate_ test:self didLog:message source:self];
}

#pragma mark Log Writer

- (void)_setLogWriter:(id<GHTestCaseLogWriter>)logWriter {
  if ([target_ respondsToSelector:@selector(setLogWriter:)])
    [target_ setLogWriter:logWriter];
} 

#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
  [coder encodeObject:identifier_ forKey:@"identifier"];
  [coder encodeBool:hidden_ forKey:@"hidden"];
  [coder encodeInteger:status_ forKey:@"status"];
  [coder encodeDouble:interval_ forKey:@"interval"];
}

- (id)initWithCoder:(NSCoder *)coder {
  GHTest *test = [self initWithIdentifier:[coder decodeObjectForKey:@"identifier"] name:nil];
  test.hidden = [coder decodeBoolForKey:@"hidden"];
  test.status = [coder decodeIntegerForKey:@"status"];
  test.interval = [coder decodeDoubleForKey:@"interval"];
  return test;
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
  if (!target_) [NSException raise:NSObjectNotAvailableException format:@"NSCopying unsupported for tests without target/selector pair"];
  return [[GHTest allocWithZone:zone] initWithTarget:target_ selector:selector_];
}

@end

//! @endcond
