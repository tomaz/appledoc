//
//  GBIvarData.m
//  appledoc
//
//  Created by Tomaz Kragelj on 26.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBIvarData.h"

@implementation GBIvarData

#pragma mark Initialization & disposal

+ (id)ivarDataWithComponents:(NSArray *)components {
	return [[[self alloc] initWithDataFromComponents:components] autorelease];
}

- (id)initWithDataFromComponents:(NSArray *)components {
	NSParameterAssert(components != nil);
	NSParameterAssert([components count] >= 2);
	self = [super init];
	if (self) {
		[self setIvarDataFromComponents:components];
	}
	return self;
}

#pragma mark Helper methods

- (void)setIvarDataFromComponents:(NSArray *)components {
	NSParameterAssert(components != nil);
	NSParameterAssert([components count] >= 2);
	NSMutableArray *types = [NSMutableArray arrayWithArray:components];
	[types removeLastObject];
	self.ivarTypes = types;
	self.ivarName = [components lastObject];
}

#pragma mark Overriden methods

- (NSString *)description {
	return self.ivarName;
}

#pragma mark Properties

@synthesize ivarName;
@synthesize ivarTypes;

@end
