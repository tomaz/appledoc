//
//  PKToken+Appledoc.m
//  appledoc
//
//  Created by Tomaz Kragelj on 1.11.12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import <objc/runtime.h>
#import "PKToken+Appledoc.h"

static const void *GBLocationKey = @"GBLocation";

@implementation PKToken (Appledoc)

- (BOOL)matches:(id)expected {
	NSUInteger result = [self matchResult:expected];
	return (result != NSNotFound);
}

- (NSUInteger)matchResult:(id)expected {
	// If expected is an array, allow if any of the objects matches. Otherwise we require exact match.
	if ([expected isKindOfClass:[NSArray class]]) {
		__block NSUInteger result = NSNotFound;
		[expected enumerateObjectsUsingBlock:^(NSString *expectedToken, NSUInteger idx, BOOL *stop) {
			if ([self.stringValue isEqual:expectedToken]) {
				result = idx;
				*stop = YES;
				return;
			}
		}];
		return result;
	} else {
		if ([self.stringValue isEqual:expected]) return 0;
	}
	return NSNotFound;
}

- (NSPoint)location {
	NSValue *storage = objc_getAssociatedObject(self, GBLocationKey);
	return [storage pointValue];
}
- (void)setLocation:(NSPoint)val {
	NSValue *storage = [NSValue valueWithPoint:val];
	objc_setAssociatedObject(self, GBLocationKey, storage, OBJC_ASSOCIATION_RETAIN);
}

@end
