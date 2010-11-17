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

#import "GRMustacheLambda_private.h"


@interface GRMustacheLambdaBlockWrapper()
+ (id)lambdaWithBlock:(GRMustacheLambdaBlock)block;
- (id)initWithBlock:(GRMustacheLambdaBlock)block;
@end


@implementation GRMustacheLambdaBlockWrapper

+ (id)lambdaWithBlock:(GRMustacheLambdaBlock)block {
	return [[[self alloc] initWithBlock:block] autorelease];
}

- (id)initWithBlock:(GRMustacheLambdaBlock)theBlock {
	if ((self = [self init])) {
		block = [theBlock copy];
	}
	return self;
}

- (NSString *)renderObject:(id)object fromString:(NSString *)templateString renderer:(GRMustacheRenderer)renderer {
	NSString *result = block(renderer, object, templateString);
	if (result == nil) {
		return @"";
	}
	return result;
}

- (NSString *)description {
	return @"<GRMustacheLambda>";
}

- (void)dealloc {
	[block release];
	[super dealloc];
}

@end


GRMustacheLambda GRMustacheLambdaMake(GRMustacheLambdaBlock block) {
	return [GRMustacheLambdaBlockWrapper lambdaWithBlock:block];
}
