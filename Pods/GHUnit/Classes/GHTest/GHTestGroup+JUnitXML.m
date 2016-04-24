//
//  GHTestGroup+JUnitXML.m
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

//! @cond DEV

#import "GHTestGroup+JUnitXML.h"


@implementation GHTestGroup(JUnitXML)

- (BOOL)writeJUnitXMLAtPath:(NSString *)path error:(NSError **)error {
  if (self.stats.testCount > 0) {
    
    NSString *XMLPath = [path stringByAppendingPathComponent:
                         [NSString stringWithFormat:@"%@.xml", self.name]];
    
    // Attempt to write the XML and return the success status
    return [[self JUnitXML] writeToFile:XMLPath atomically:NO encoding:NSUTF8StringEncoding error:error];
  }
  return YES;
}

- (NSString *)JUnitXML {
  NSMutableString *JUnitXML = [NSMutableString stringWithFormat:
                               @"<testsuite name=\"%@\" tests=\"%d\" failures=\"%d\" time=\"%0.4f\">",
                               self.name, self.stats.testCount, self.stats.failureCount, self.interval];
  
  for (id child in self.children) {
    if ([child respondsToSelector:@selector(JUnitXML)])
      [JUnitXML appendString:[child JUnitXML]];
  }
  [JUnitXML appendString:@"</testsuite>"];
  return JUnitXML;
}

@end

//! @endcond
