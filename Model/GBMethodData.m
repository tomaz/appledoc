//
//  GBMethodData.m
//  appledoc
//
//  Created by Tomaz Kragelj on 26.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBMethodArgument.h"
#import "GBMethodData.h"

@interface GBMethodData ()

- (NSString *)selectorFromAssignedData;

@end

#pragma mark -

@implementation GBMethodData

#pragma mark Initialization & disposal

+ (id)methodDataWithType:(GBMethodType)type result:(NSArray *)result arguments:(NSArray *)arguments {
	NSParameterAssert([arguments count] >= 1);
	return [[[self alloc] initWithType:type attributes:nil result:result arguments:arguments] autorelease];
}

+ (id)propertyDataWithAttributes:(NSArray *)attributes components:(NSArray *)components {
	NSParameterAssert([components count] >= 2);	// At least one return and the name!
	NSMutableArray *results = [NSMutableArray arrayWithArray:components];
	[results removeLastObject];
	GBMethodArgument *argument = [GBMethodArgument methodArgumentWithName:[components lastObject]];
	return [[[self alloc] initWithType:GBMethodTypeProperty attributes:attributes result:results arguments:[NSArray arrayWithObject:argument]] autorelease];
}

- (id)initWithType:(GBMethodType)type attributes:(NSArray *)attributes result:(NSArray *)result arguments:(NSArray *)arguments {
	self = [super init];
	if (self) {
		_methodType = type;
		_methodAttributes = attributes;
		_methodResultTypes = [result retain];
		_methodArguments = [arguments retain];
		_methodSelector = [[self selectorFromAssignedData] retain];
	}
	return self;
}

#pragma mark Helper methods

- (NSString *)selectorFromAssignedData {
	NSMutableString *result = [NSMutableString string];
	NSString *delimiter = ([self.methodArguments count] > 1 || [[self.methodArguments lastObject] isTyped]) ? @":" : @"";
	for (GBMethodArgument *argument in self.methodArguments) {
		[result appendString:argument.argumentName];
		[result appendString:delimiter];
	}
	return result;
}

#pragma mark Overidden methods

- (void)mergeDataFromObject:(id)source {
	if (!source || source == self) return;
	GBLogDebug(@"Merging data from %@...", source);
	NSParameterAssert([source methodType] == self.methodType);
	NSParameterAssert([source methodAttributes] == self.methodAttributes || [[source methodAttributes] isEqualToArray:self.methodAttributes]); // allow nil!
	NSParameterAssert([[source methodSelector] isEqualToString:self.methodSelector]);
	NSParameterAssert([[source methodResultTypes] isEqualToArray:self.methodResultTypes]);
	[super mergeDataFromObject:source];
}

- (NSString *)description {
	return self.methodSelector;
}

#pragma mark Properties

@synthesize methodType = _methodType;
@synthesize methodAttributes = _methodAttributes;
@synthesize methodResultTypes = _methodResultTypes;
@synthesize methodArguments = _methodArguments;
@synthesize methodSelector = _methodSelector;

@end
