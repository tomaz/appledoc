//
//  GHTest+JUnitXML.m
//  GHUnit
//
//  Created by Gabriel Handford on 6/4/10.
//  Copyright 2010. All rights reserved.
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

#import "GHTest+JUnitXML.h"
#import "GHTesting.h"
#import "GTMNSString+XML.h"

//! @cond DEV

@implementation GHTest(JUnitXML)

- (NSString *)JUnitXML {
  return [NSString stringWithFormat:
          @"<testcase name=\"%@\" classname=\"%@\" time=\"%0.4f\">%@</testcase>",
          self.name, [self.target class], self.interval,
          (self.exception ? [NSString stringWithFormat:@"<failure message=\"%@\">%@</failure>", [[self.exception description] gtm_stringBySanitizingAndEscapingForXML], 
                             [[GHTesting descriptionForException:self.exception] gtm_stringBySanitizingAndEscapingForXML]] : @"")];
}

@end

//! @endcond
