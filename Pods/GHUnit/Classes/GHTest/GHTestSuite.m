//
//  GHTestSuite.m
//  GHUnit
//
//  Created by Gabriel Handford on 1/25/09.
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

#import "GHTestSuite.h"

#import "GHTesting.h"
#import "GHTestGroup+JUnitXML.h"

NSString *GHUnitTest = NULL;

@interface GHTestSuite (CLIDisabled)
- (BOOL)isCLIDisabled;
@end

@implementation GHTestSuite

- (id)initWithName:(NSString *)name testCases:(NSArray *)testCases delegate:(id<GHTestDelegate>)delegate {
  if ((self = [super initWithName:name delegate:delegate])) {
    for(id testCase in testCases) {
      [self addTestCase:testCase];
    }
  }
  return self;
}

+ (GHTestSuite *)allTests {
  NSArray *testCases = [[GHTesting sharedInstance] loadAllTestCases];
  GHTestSuite *allTests = [[self alloc] initWithName:@"Tests" testCases:nil delegate:nil];  
  for(id testCase in testCases) {
    // Ignore test cases that can't be run at the command line
    if (!([testCase respondsToSelector:@selector(isCLIDisabled)] && [testCase isCLIDisabled] && getenv("GHUNIT_CLI"))) [allTests addTestCase:testCase];
  }
  return allTests;
}

+ (GHTestSuite *)suiteWithTestCaseClass:(Class)testCaseClass method:(SEL)method { 
  NSString *name = [NSString stringWithFormat:@"%@/%@", NSStringFromClass(testCaseClass), NSStringFromSelector(method)];
  GHTestSuite *testSuite = [[GHTestSuite alloc] initWithName:name testCases:nil delegate:nil];
  id testCase = [[testCaseClass alloc] init];
  if (!testCase) {
    NSLog(@"Couldn't instantiate test: %@", NSStringFromClass(testCaseClass));
    return nil;
  }
  GHTestGroup *group = [[GHTestGroup alloc] initWithTestCase:testCase selector:method delegate:nil];
  [testSuite addTestGroup:group];
  return testSuite;
}

+ (GHTestSuite *)suiteWithPrefix:(NSString *)prefix options:(NSStringCompareOptions)options {
  if (!prefix || [prefix isEqualToString:@""]) return [self allTests];
  
  NSArray *testCases = [[GHTesting sharedInstance] loadAllTestCases];
  NSString *name = [NSString stringWithFormat:@"Tests (%@)", prefix];
  GHTestSuite *testSuite = [[self alloc] initWithName:name testCases:nil delegate:nil]; 
  for(id testCase in testCases) {
    NSString *className = NSStringFromClass([testCase class]);    
    if ([className compare:prefix options:options range:NSMakeRange(0, [prefix length])] == NSOrderedSame)
      [testSuite addTestCase:testCase];
  }
  return testSuite;
  
}

+ (GHTestSuite *)suiteWithTestFilter:(NSString *)testFilterString {
  NSArray *testFilters = [testFilterString componentsSeparatedByString:@","];
  GHTestSuite *testSuite = [[GHTestSuite alloc] initWithName:testFilterString testCases:nil delegate:nil];

  for(NSString *testFilter in testFilters) {
    NSArray *components = [testFilter componentsSeparatedByString:@"/"];
    if ([components count] == 2) {    
      NSString *testCaseClassName = [components objectAtIndex:0];
      Class testCaseClass = NSClassFromString(testCaseClassName);
      id testCase = [[testCaseClass alloc] init];
      if (!testCase) {
        NSLog(@"Couldn't find test: %@", testCaseClassName);
        continue;
      }
      NSString *methodName = [components objectAtIndex:1];
      GHTestGroup *group = [[GHTestGroup alloc] initWithTestCase:testCase selector:NSSelectorFromString(methodName) delegate:nil];
      [testSuite addTestGroup:group];
    } else {
      Class testCaseClass = NSClassFromString(testFilter);
      id testCase = [[testCaseClass alloc] init];
      if (!testCase) {
        NSLog(@"Couldn't find test: %@", testFilter);
        continue;
      }   
      [testSuite addTestCase:testCase];
    }
  }
  
  return testSuite;
}

+ (GHTestSuite *)suiteFromEnv {
  const char* cTestFilter = getenv("TEST");
  if (cTestFilter) {
    NSString *testFilter = [NSString stringWithUTF8String:cTestFilter];
    return [GHTestSuite suiteWithTestFilter:testFilter];
  } else {  
    if (GHUnitTest != NULL) return [GHTestSuite suiteWithTestFilter:GHUnitTest];
    return [GHTestSuite allTests];
  }
}

@end

@implementation GHTestSuite (JUnitXML)

/*
 Override logic to write children individually, as we want each test group's
 JUnit XML to be in its own file.
 */
- (BOOL)writeJUnitXMLToDirectory:(NSString *)directory error:(NSError **)error {
  NSParameterAssert(error);
  BOOL allSuccess = YES;
  
  NSFileManager *fileManager = [NSFileManager defaultManager];
  if (![fileManager fileExistsAtPath:directory]) {
    if (![fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:error]) {
      NSLog(@"Error while creating results directory: %@", [*error localizedDescription]);
      return NO;
    }
  }
    
  for (id child in self.children) {
    if ([child respondsToSelector:@selector(writeJUnitXMLAtPath:error:)]) {
      if (![child writeJUnitXMLAtPath:directory error:error]) {
        NSLog(@"Error writing JUnit XML: %@", [*error localizedDescription]);
        allSuccess = NO;
      }
    }
  }
  return allSuccess;
}

@end

//! @endcond
