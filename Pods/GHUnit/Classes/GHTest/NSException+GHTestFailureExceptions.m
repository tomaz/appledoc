//
//  NSException+GHTestFailureExceptions.m
//
//  Created by Johannes Rudolph on 23.09.09.
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

// GTM_BEGIN - Contains modifications by JR

#import <Foundation/Foundation.h>

#import "NSException+GHTestFailureExceptions.h"

#import "NSValue+GHValueFormatter.h"

NSString *const GHTestFilenameKey = @"GHTestFilenameKey";
NSString *const GHTestLineNumberKey = @"GHTestLineNumberKey";
NSString *const GHTestFailureException = @"GHTestFailureException";

@interface NSException(GHTestFailureExceptionsPrivateAdditions)
+ (NSException *)ghu_failureInFile:(NSString *)filename
                        atLine:(int)lineNumber
                        reason:(NSString *)reason;
@end

@implementation NSException(GHTestFailureExceptionsPrivateAdditions)
+ (NSException *)ghu_failureInFile:(NSString *)filename
                        atLine:(int)lineNumber
                        reason:(NSString *)reason {
  NSDictionary *userInfo =
  [NSDictionary dictionaryWithObjectsAndKeys:
   [NSNumber numberWithInteger:lineNumber], GHTestLineNumberKey,
   filename, GHTestFilenameKey,
   nil];
  
  return [self exceptionWithName:GHTestFailureException
              reason:reason
              userInfo:userInfo];
}
@end

@implementation NSException(GHTestFailureExceptions)

+ (NSException *)ghu_failureInFile:(NSString *)filename
                        atLine:(int)lineNumber
               withDescription:(NSString *)formatString, ... {
  
  NSString *testDescription = @"";
  if (formatString) {
    va_list vl;
    va_start(vl, formatString);
    testDescription =
    [[NSString alloc] initWithFormat:formatString arguments:vl];
    va_end(vl);
  }
  
  NSString *reason = testDescription;
  
  return [self ghu_failureInFile:filename atLine:lineNumber reason:reason];
}

+ (NSException *)ghu_failureInCondition:(NSString *)condition
                             isTrue:(BOOL)isTrue
                             inFile:(NSString *)filename
                             atLine:(int)lineNumber
                    withDescription:(NSString *)formatString, ... {
  
  NSString *testDescription = @"";
  if (formatString) {
    va_list vl;
    va_start(vl, formatString);
    testDescription =
    [[NSString alloc] initWithFormat:formatString arguments:vl];
    va_end(vl);
  }
  
  NSString *reason = [NSString stringWithFormat:@"'%@' should be %s. %@",
            condition, isTrue ? "TRUE" : "FALSE", testDescription];
  
  return [self ghu_failureInFile:filename atLine:lineNumber reason:reason];
}

+ (NSException *)ghu_failureInEqualityBetweenObject:(id)left
                                      andObject:(id)right
                                         inFile:(NSString *)filename
                                         atLine:(int)lineNumber
                                withDescription:(NSString *)formatString, ... {
  
  NSString *testDescription = @"";
  if (formatString) {
    va_list vl;
    va_start(vl, formatString);
    testDescription =
    [[NSString alloc] initWithFormat:formatString arguments:vl];
    va_end(vl);
  }
  
  NSString *reason =
  [NSString stringWithFormat:@"'%@' should be equal to '%@'. %@",
   [left description], [right description], testDescription];
  
  return [self ghu_failureInFile:filename atLine:lineNumber reason:reason];
}

+ (NSException *)ghu_failureInInequalityBetweenObject:(id)left
                                          andObject:(id)right
                                             inFile:(NSString *)filename
                                             atLine:(int)lineNumber
                                    withDescription:(NSString *)formatString, ... {
  
  NSString *testDescription = @"";
  if (formatString) {
    va_list vl;
    va_start(vl, formatString);
    testDescription =
    [[NSString alloc] initWithFormat:formatString arguments:vl];
    va_end(vl);
  }
  
  NSString *reason =
  [NSString stringWithFormat:@"'%@' should not be equal to '%@'. %@",
   [left description], [right description], testDescription];
  
  return [self ghu_failureInFile:filename atLine:lineNumber reason:reason];
}

+ (NSException *)ghu_failureInEqualityBetweenValue:(NSValue *)left
                                      andValue:(NSValue *)right
                                  withAccuracy:(NSValue *)accuracy
                                        inFile:(NSString *)filename
                                        atLine:(int)lineNumber
                               withDescription:(NSString *)formatString, ... {
  
  NSString *testDescription = @"";
  if (formatString) {
    va_list vl;
    va_start(vl, formatString);
    testDescription =
    [[NSString alloc] initWithFormat:formatString arguments:vl];
    va_end(vl);
  }
  
  NSString *reason;
  if (!accuracy) {
    reason =
    [NSString stringWithFormat:@"'%@' should be equal to '%@'. %@",
     [left ghu_contentDescription], [right ghu_contentDescription], testDescription];
  } else {
    reason =
    [NSString stringWithFormat:@"'%@' should be equal to '%@' +/-'%@'. %@",
     [left ghu_contentDescription], [right ghu_contentDescription], [accuracy ghu_contentDescription], testDescription];
  }
  
  return [self ghu_failureInFile:filename atLine:lineNumber reason:reason];
}

+ (NSException *)ghu_failureInRaise:(NSString *)expression
                         inFile:(NSString *)filename
                         atLine:(int)lineNumber
                withDescription:(NSString *)formatString, ... {
  
  NSString *testDescription = @"";
  if (formatString) {
    va_list vl;
    va_start(vl, formatString);
    testDescription =
    [[NSString alloc] initWithFormat:formatString arguments:vl];
    va_end(vl);
  }
  
  NSString *reason = [NSString stringWithFormat:@"'%@' should raise. %@",
            expression, testDescription];
  
  return [self ghu_failureInFile:filename atLine:lineNumber reason:reason];
}

+ (NSException *)ghu_failureInRaise:(NSString *)expression
                      exception:(NSException *)exception
                         inFile:(NSString *)filename
                         atLine:(int)lineNumber
                withDescription:(NSString *)formatString, ... {
  
  NSString *testDescription = @"";
  if (formatString) {
    va_list vl;
    va_start(vl, formatString);
    testDescription =
    [[NSString alloc] initWithFormat:formatString arguments:vl];
    va_end(vl);
  }
  
  NSString *reason;
  if ([[exception name] isEqualToString:GHTestFailureException]) {
    // it's our exception, assume it has the right description on it.
    reason = [exception reason];
  } else {
    // not one of our exception, use the exceptions reason and our description
    reason = [NSString stringWithFormat:@"'%@' raised '%@'. %@",
          expression, [exception reason], testDescription];
  }
  
  return [self ghu_failureInFile:filename atLine:lineNumber reason:reason];
}

+ (NSException *)ghu_failureWithName:(NSString *)name
                              inFile:(NSString *)filename
                              atLine:(int)lineNumber
                              reason:(NSString *)reason {
  NSDictionary *userInfo =
  [NSDictionary dictionaryWithObjectsAndKeys:
   [NSNumber numberWithInteger:lineNumber], GHTestLineNumberKey,
   filename, GHTestFilenameKey,
   nil];
  
  return [self exceptionWithName:name
                          reason:reason
                        userInfo:userInfo];
}

@end

NSString *GHComposeString(NSString *formatString, ...) {
  NSString *reason = @"";
  if (formatString) {
    va_list vl;
    va_start(vl, formatString);
    reason =
    [[NSString alloc] initWithFormat:formatString arguments:vl];
    va_end(vl);
  }
  return reason;
}

// GTM_END

//! @endcond
