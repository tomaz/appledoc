//
//  NSValue+GHValueFormatter.m
//
//  Created by Johannes Rudolph on 23.9.2009.
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
// Portions of this file fall under the following license, marked with
// SENTE_BEGIN - SENTE_END
//
// Copyright (c) 1997-2005, Sen:te (Sente SA).  All rights reserved.
//
// Use of this source code is governed by the following license:
// 
// Redistribution and use in source and binary forms, with or without modification, 
// are permitted provided that the following conditions are met:
// 
// (1) Redistributions of source code must retain the above copyright notice, 
// this list of conditions and the following disclaimer.
// 
// (2) Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation 
// and/or other materials provided with the distribution.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ``AS IS'' 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
// IN NO EVENT SHALL Sente SA OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT 
// OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, 
// EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// 
// Note: this license is equivalent to the FreeBSD license.
// 
// This notice may not be removed from this file.


#import "NSValue+GHValueFormatter.h"

// SENTE_BEGIN

@implementation NSValue(GHValueFormatter)
- (NSString *)ghu_contentDescription {
  const char *objCType = [self objCType];
  if (objCType != NULL) {
    if (strlen (objCType) == 1) {
      switch (objCType[0]) {
        case 'c': {
          char scalarValue = 0;
          [self getValue:(void *)&scalarValue];
          return [NSString stringWithFormat:@"%c", scalarValue];
        }
        case 'C': {
          unsigned char scalarValue = 0;
          [self getValue:(void *)&scalarValue];
          return [NSString stringWithFormat:@"%c", scalarValue];
        }
        case 's': {
          short scalarValue = 0;
          [self getValue:(void *)&scalarValue];
          return [NSString stringWithFormat:@"%hi", scalarValue];
        }
        case 'S': {
          unsigned short scalarValue = 0;
          [self getValue:(void *)&scalarValue];
          return [NSString stringWithFormat:@"%hu", scalarValue];
        }
        case 'l': {
          long scalarValue = 0;
          [self getValue:(void *)&scalarValue];
          return [NSString stringWithFormat:@"%li", scalarValue];
        }
        case 'L': {
          unsigned long scalarValue = 0;
          [self getValue:(void *)&scalarValue];
          return [NSString stringWithFormat:@"%lu", scalarValue];
        }
        case 'q': {
          long long scalarValue = 0;
          [self getValue:(void *)&scalarValue];
          return [NSString stringWithFormat:@"%lli", scalarValue];
        }
        case 'Q': {
          unsigned long long scalarValue = 0;
          [self getValue:(void *)&scalarValue];
          return [NSString stringWithFormat:@"%llu", scalarValue];
        }
        case 'i': {
          int scalarValue = 0;
          [self getValue:(void *)&scalarValue];
          return [NSString stringWithFormat:@"%i", scalarValue];
        }
        case 'I': {
          unsigned int long scalarValue = 0;
          [self getValue:(void *)&scalarValue];
          return [NSString stringWithFormat:@"%lu", scalarValue];
        }
        case 'f': {
          float scalarValue = 0.0f;
          [self getValue:(void *)&scalarValue];
          return [NSString stringWithFormat:@"%f", scalarValue];
        }
        case 'd': {
          double scalarValue = 0.0;
          [self getValue:(void *)&scalarValue];
          return [NSString stringWithFormat:@"%.12g", scalarValue];
        }
        default: {
          return [self description];
        }
      }
    }
    else if (strncmp (objCType, "^", 1) == 0) {
      return [NSString stringWithFormat:@"%p", [self pointerValue]];
    } 
    //else if (strcmp (objCType, "{_NSPoint=ff}") == 0) {
//      return [NSString stringWithFormat:@"%@", NSStringFromPoint ([self pointValue])];  
//    } 
//    else if (strcmp (objCType, "{_NSSize=ff}") == 0) {
//      return [NSString stringWithFormat:@"%@", NSStringFromSize ([self sizeValue])];  
//    } 
//    else if (strcmp (objCType, "{_NSRange=II}") == 0) {
//      return [NSString stringWithFormat:@"%@", NSStringFromRange ([self rangeValue])];    
//    } 
//    else if (strcmp (objCType, "{_NSRect={_NSPoint=ff}{_NSSize=ff}}") == 0) {
//      return [NSString stringWithFormat:@"%@", NSStringFromRect ([self rectValue])];      
//    }
  }
  return [self description];
}
@end

// SENTE_END

//! @endcond
