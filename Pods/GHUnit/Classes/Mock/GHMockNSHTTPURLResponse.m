//
//  GHMockNSHTTPURLResponse.m
//  GHUnit
//
//  Created by Gabriel Handford on 4/9/09.
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

#import "GHMockNSHTTPURLResponse.h"

@implementation GHMockNSHTTPURLResponse

- (id)initWithStatusCode:(NSInteger)statusCode headers:(NSDictionary *)headers {
	if ((self = [super init])) {
		[self setStatusCode:statusCode];
		[self setHeaders:headers];
	}
	return self;
}

- (void)setStatusCode:(NSInteger)code {
	statusCode_ = code;
}

- (NSInteger)statusCode {
	return statusCode_ ? statusCode_ : [super statusCode];
}

- (void)setHeaders:(NSDictionary *)headers {
	headers_ = headers;
}

- (NSDictionary *)allHeaderFields {
	return headers_ ? [headers_ copy] : [super allHeaderFields];
}

@end

//! @endcond
