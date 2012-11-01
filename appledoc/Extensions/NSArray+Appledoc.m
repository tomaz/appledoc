//
//  NSArray+Appledoc.m
//  appledoc
//
//  Created by Tomaz Kragelj on 1.11.12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "NSArray+Appledoc.h"

@implementation NSArray (Appledoc)

- (BOOL)gb_containsObjectWithValue:(id)value forSelector:(SEL)selector {
	NSUInteger index = [self gb_indexOfObjectWithValue:value forSelector:selector];
	return (index != NSNotFound);
}

- (NSUInteger)gb_indexOfObjectWithValue:(id)value forSelector:(SEL)selector {
	// Note that it's ok to ignore the warning here as long as the method corresponding to the given selector returns an object... See more here http://stackoverflow.com/questions/8855461/did-the-target-action-design-pattern-became-bad-practice-under-arc
	__block NSUInteger result = NSNotFound;
	[self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
		id objValue = [obj performSelector:selector];
#pragma clang diagnostic pop
		if ([objValue isEqual:value]) {
			result = idx;
			*stop = YES;
		}
	}];
	return result;
}

@end
