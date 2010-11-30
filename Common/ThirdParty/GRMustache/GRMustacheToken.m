// The MIT License
// 
// Copyright (c) 2010 Gwendal Roué
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "GRMustacheToken_private.h"


@interface GRMustacheToken()
@property (nonatomic, retain) NSString *content;
- (id)initWithType:(GRMustacheTokenType)type content:(NSString *)content line:(NSUInteger)line range:(NSRange)range;
@end

@implementation GRMustacheToken
@synthesize type;
@synthesize content;
@synthesize line;
@synthesize range;

+ (id)tokenWithType:(GRMustacheTokenType)type content:(NSString *)content line:(NSUInteger)line range:(NSRange)range {
	return [[[self alloc] initWithType:type content:content line:line range:range] autorelease];
}

- (id)initWithType:(GRMustacheTokenType)theType content:(NSString *)theContent line:(NSUInteger)theLine range:(NSRange)theRange {
	if ((self = [self init])) {
		type = theType;
		content = [theContent retain];
		line = theLine;
		range = theRange;
	}
	return self;
}

- (void)dealloc {
	[content release];
	[super dealloc];
}

@end

