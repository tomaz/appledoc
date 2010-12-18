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

#import "GRMustache_private.h"
#import "GRMustacheLambda_private.h"


static BOOL strictBooleanMode = NO;

@implementation GRMustache

+ (BOOL)strictBooleanMode {
	return strictBooleanMode;
}

+ (void)setStrictBooleanMode:(BOOL)aBool {
	strictBooleanMode = aBool;
}

+ (GRMustacheObjectKind)objectKind:(id)object {
	if (object == nil || object == [NSNull null] || object == [GRNo no] || ([object isKindOfClass:[NSString class]] && ((NSString*)object).length == 0)) {
		return GRMustacheObjectKindFalseValue;
	}
	if ([object isKindOfClass:[NSDictionary class]]) {
		return GRMustacheObjectKindTrueValue;
	}
	if ([object conformsToProtocol:@protocol(NSFastEnumeration)]) {
		return GRMustacheObjectKindEnumerable;
	}
	if ([object isKindOfClass:[GRMustacheLambdaBlockWrapper class]]) {
		return GRMustacheObjectKindLambda;
	}
	return GRMustacheObjectKindTrueValue;
}

@end
