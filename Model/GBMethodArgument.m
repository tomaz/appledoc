//
//  GBMethodArgument.m
//  appledoc
//
//  Created by Tomaz Kragelj on 26.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBMethodArgument.h"

@implementation GBMethodArgument

#pragma mark Initialization & disposal

+ (id)methodArgumentWithName:(NSString *)name types:(NSArray *)types var:(NSString *)var {
	return [[self alloc] initWithName:name types:types var:var];
}

+ (id)methodArgumentWithName:(NSString *)name {
	return [[self alloc] initWithName:name];
}

- (id)initWithName:(NSString *)name types:(NSArray *)types var:(NSString *)var {
	NSParameterAssert(name != nil);
	NSParameterAssert((types == nil && var == nil) || (types != nil && var != nil));
	self = [super init];
	if (self) {
		_argumentName = [name copy];
		_argumentTypes = [types retain];
		_argumentVar = [var copy];
	}
	return self;
}

- (id)initWithName:(NSString *)name {
	return [self initWithName:name types:nil var:nil];
}

#pragma mark Overriden methods

- (NSString *)description {
	if (self.argumentTypes && self.argumentVar) {
		__block NSMutableString *typeValue = [NSMutableString string];
		[self.argumentTypes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			[typeValue appendFormat:@"%@", obj];
			if (idx < [self.argumentTypes count] - 1) [typeValue appendString:@" "];
		}];
		return [NSString stringWithFormat:@"%@:(%@)%@", self.argumentName, typeValue, self.argumentVar];
	}
	return self.argumentName;
}

#pragma mark Properties

- (BOOL)isTyped {
	return (self.argumentTypes != nil && self.argumentVar != nil);
}

@synthesize argumentName = _argumentName;
@synthesize argumentTypes = _argumentTypes;
@synthesize argumentVar = _argumentVar;

@end
