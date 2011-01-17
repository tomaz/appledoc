//
//  NSArray+GBArray.m
//  appledoc
//
//  Created by Tomaz Kragelj on 13.1.11.
//  Copyright 2011 Gentle Bytes. All rights reserved.
//

#import "NSArray+GBArray.h"

@implementation NSArray (GBArray)

- (id)firstObject {
	if ([self count] == 0) return nil;
	return [self objectAtIndex:0];
}

- (BOOL)isEmpty {
	return ([self count] == 0);
}

@end

#pragma mark -

@implementation NSMutableArray (GBMutableArray)

- (void)push:(id)object {
	[self addObject:object];
}

- (id)pop {
	id result = [self peek];
	[self removeLastObject];
	return result;
}

- (id)peek {
	return [self lastObject];
}

@end