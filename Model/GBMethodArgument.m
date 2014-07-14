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

+ (id)methodArgumentWithName:(NSString *)name types:(NSArray *)types var:(NSString *)var variableArg:(BOOL)variableArg terminationMacros:(NSArray *)macros {
	return [[self alloc] initWithName:name types:types var:var variableArg:variableArg terminationMacros:macros];
}

+ (id)methodArgumentWithName:(NSString *)name types:(NSArray *)types var:(NSString *)var {
	return [self methodArgumentWithName:name types:types var:var variableArg:NO terminationMacros:nil];
}

+ (id)methodArgumentWithName:(NSString *)name {
	return [self methodArgumentWithName:name types:[NSArray array] var:nil variableArg:NO terminationMacros:nil];
}

- (id)initWithName:(NSString *)name types:(NSArray *)types var:(NSString *)var variableArg:(BOOL)variableArg terminationMacros:(NSArray *)macros {
	NSParameterAssert(name != nil);
	if ([types count] == 0 && var != nil) types = [NSArray arrayWithObject:@"id"];
	self = [super init];
	if (self) {
		_argumentName = [name copy];
		_argumentTypes = types;
		_argumentVar = [var copy];
		_terminationMacros = macros ? macros : [[NSArray alloc] init];
		self.isVariableArg = variableArg;
	}
	return self;
}

#pragma mark Overriden methods

- (NSString *)description {
	if ([self.argumentTypes count] && self.argumentVar) {
		NSMutableString *typeValue = [NSMutableString string];
		[self.argumentTypes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			[typeValue appendFormat:@"%@", obj];
			if (idx < [self.argumentTypes count] - 1) [typeValue appendString:@" "];
		}];
		NSMutableString *terminationValue = [NSMutableString string];
		[self.terminationMacros enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			[terminationValue appendFormat:@"%@", obj];
			if (idx < [self.argumentTypes count] - 1) [typeValue appendString:@" "];
		}];
		return [NSString stringWithFormat:@"%@:(%@)%@%@%@", self.argumentName, typeValue, self.argumentVar, self.isVariableArg ? @",..." : @"", terminationValue];
	}
	return self.argumentName;
}

#pragma mark Properties

- (BOOL)isTyped {
	return ([self.argumentTypes count] > 0 && self.argumentVar != nil);
}

@synthesize argumentName = _argumentName;
@synthesize argumentTypes = _argumentTypes;
@synthesize argumentVar = _argumentVar;
@synthesize terminationMacros = _terminationMacros;
@synthesize isVariableArg;

@end
