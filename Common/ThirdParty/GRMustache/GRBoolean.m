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

#import "GRBoolean.h"


static GRYes *yes = nil;

@implementation GRYes

+ (GRYes *)yes {
    if (yes == nil) {
		yes = [[super allocWithZone:NULL] init];
	}
	return yes;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [[self yes] retain];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

- (id)valueForKey:(NSString *)key {
	return nil;
}

- (BOOL)boolValue {
	return YES;
}

- (NSString *)description {
	return @"(yes)";
}

@end

static GRNo *no = nil;

@implementation GRNo

+ (GRNo *)no {
    if (no == nil) {
		no = [[super allocWithZone:NULL] init];
	}
	return no;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [[self no] retain];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

- (id)valueForKey:(NSString *)key {
	return nil;
}

- (BOOL)boolValue {
	return NO;
}

- (NSString *)description {
	return @"(no)";
}

@end
