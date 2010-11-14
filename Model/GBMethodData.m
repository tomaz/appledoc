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
- (NSString *)selectorDelimiterFromAssignedData;
- (NSString *)prefixFromAssignedData;
- (BOOL)formatTypesFromArray:(NSArray *)types toArray:(NSMutableArray *)array prefix:(NSString *)prefix suffix:(NSString *)suffix;
- (NSDictionary *)formattedComponentWithValue:(NSString *)value;
- (NSDictionary *)formattedComponentWithValue:(NSString *)value style:(NSUInteger)style href:(NSString *)href;

@end

#pragma mark -

@implementation GBMethodData

#pragma mark Initialization & disposal

+ (id)methodDataWithType:(GBMethodType)type result:(NSArray *)result arguments:(NSArray *)arguments {
	NSParameterAssert([arguments count] >= 1);
	return [[[self alloc] initWithType:type attributes:[NSArray array] result:result arguments:arguments] autorelease];
}

+ (id)propertyDataWithAttributes:(NSArray *)attributes components:(NSArray *)components {
	NSParameterAssert([components count] >= 2);	// At least one return and the name!
	NSMutableArray *results = [NSMutableArray arrayWithArray:components];
	[results removeLastObject];	// Remove ;
	GBMethodArgument *argument = [GBMethodArgument methodArgumentWithName:[components lastObject]];
	return [[[self alloc] initWithType:GBMethodTypeProperty attributes:attributes result:results arguments:[NSArray arrayWithObject:argument]] autorelease];
}

- (id)initWithType:(GBMethodType)type attributes:(NSArray *)attributes result:(NSArray *)result arguments:(NSArray *)arguments {
	self = [super init];
	if (self) {
		_methodType = type;
		_methodAttributes = [attributes retain];
		_methodResultTypes = [result retain];
		_methodArguments = [arguments retain];
		_methodSelectorDelimiter = [[self selectorDelimiterFromAssignedData] retain];
		_methodSelector = [[self selectorFromAssignedData] retain];
		_methodPrefix = [[self prefixFromAssignedData] retain];
	}
	return self;
}

#pragma mark Formatted components handling

- (NSArray *)formattedComponents {
	NSMutableArray *result = [NSMutableArray array];
	if (self.methodType == GBMethodTypeProperty) {
		// Add property keyword and space.
		[result addObject:[self formattedComponentWithValue:@"@property"]];
		[result addObject:[self formattedComponentWithValue:@" "]];
		
		// Add the list of attributes.
		[result addObject:[self formattedComponentWithValue:@"("]];
		[self.methodAttributes enumerateObjectsUsingBlock:^(NSString *attribute, NSUInteger idx, BOOL *stop) {
			[result addObject:[self formattedComponentWithValue:attribute]];
			if (idx < [self.methodAttributes count]-1) {
				[result addObject:[self formattedComponentWithValue:@","]];
				[result addObject:[self formattedComponentWithValue:@" "]];
			}
		}];
		[result addObject:[self formattedComponentWithValue:@")"]];
		[result addObject:[self formattedComponentWithValue:@" "]];
		
		// Add the list of resulting types, append space unless last component was * and property name.
		if (![self formatTypesFromArray:self.methodResultTypes toArray:result prefix:nil suffix:nil]) {
			[result addObject:[self formattedComponentWithValue:@" "]];
		}
		[result addObject:[self formattedComponentWithValue:self.methodSelector]];
	} else {
		// Add prefix.
		[result addObject:[self formattedComponentWithValue:(self.methodType == GBMethodTypeInstance) ? @"-" : @"+"]];
		[result addObject:[self formattedComponentWithValue:@" "]];
		
		// Add return types, then append all arguments.
		[self formatTypesFromArray:self.methodResultTypes toArray:result prefix:@"(" suffix:@")"];
		[self.methodArguments enumerateObjectsUsingBlock:^(GBMethodArgument *argument, NSUInteger idx, BOOL *stop) {
			[result addObject:[self formattedComponentWithValue:argument.argumentName]];
			if (argument.isTyped) {
				[result addObject:[self formattedComponentWithValue:@":"]];
				[self formatTypesFromArray:argument.argumentTypes toArray:result prefix:@"(" suffix:@")"];
				if (argument.argumentVar) [result addObject:[self formattedComponentWithValue:argument.argumentVar style:1 href:nil]];
			}
			if (idx < [self.methodArguments count]-1) [result addObject:[self formattedComponentWithValue:@" "]];
		}];
	}
	return result;
}

- (BOOL)formatTypesFromArray:(NSArray *)types toArray:(NSMutableArray *)array prefix:(NSString *)prefix suffix:(NSString *)suffix {
	BOOL hasValues = [types count] > 0;
	if (hasValues && prefix) [array addObject:[self formattedComponentWithValue:prefix]];
	
	__block BOOL lastCompWasPointer = NO;
	[types enumerateObjectsUsingBlock:^(NSString *type, NSUInteger idx, BOOL *stop) {
		[array addObject:[self formattedComponentWithValue:type]];
		BOOL isLast = (idx == [types count] - 1);
		BOOL isPointer = [type isEqualToString:@"*"];
		if (!isLast && !isPointer) [array addObject:[self formattedComponentWithValue:@" "]];
		lastCompWasPointer = isPointer;
	}];
	
	if (hasValues && suffix) [array addObject:[self formattedComponentWithValue:suffix]];
	return lastCompWasPointer;
}

- (NSDictionary *)formattedComponentWithValue:(NSString *)value {
	return [self formattedComponentWithValue:value style:0 href:nil];
}

- (NSDictionary *)formattedComponentWithValue:(NSString *)value style:(NSUInteger)style href:(NSString *)href {
	NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:3];
	[result setObject:value forKey:@"value"];
	if (style > 0) [result setObject:[NSNumber numberWithUnsignedInt:style] forKey:@"style"];
	if (href) [result setObject:href forKey:@"href"];
	return result;
}

#pragma mark Helper methods

- (NSString *)selectorFromAssignedData {
	NSMutableString *result = [NSMutableString string];
	for (GBMethodArgument *argument in self.methodArguments) {
		[result appendString:argument.argumentName];
		[result appendString:self.methodSelectorDelimiter];
	}
	return result;
}

- (NSString *)selectorDelimiterFromAssignedData {
	if ([self.methodArguments count] > 1 || [[self.methodArguments lastObject] isTyped]) return @":";
	return @"";
}

- (NSString *)prefixFromAssignedData {
	switch (self.methodType) {
		case GBMethodTypeClass: return @"+";
		case GBMethodTypeInstance: return @"-";
	}
	return @"";
}

#pragma mark Overidden methods

- (void)mergeDataFromObject:(id)source {
	if (!source || source == self) return;
	GBLogDebug(@"%@: Merging data from %@...", self, source);
	NSParameterAssert([source methodType] == self.methodType);
	NSParameterAssert([source methodAttributes] == self.methodAttributes || [[source methodAttributes] isEqualToArray:self.methodAttributes]); // allow nil!
	NSParameterAssert([[source methodSelector] isEqualToString:self.methodSelector]);
	NSParameterAssert([[source methodResultTypes] isEqualToArray:self.methodResultTypes]);
	[super mergeDataFromObject:source];
}

- (NSString *)description {
	if (self.parentObject) {
		switch (self.methodType) {
			case GBMethodTypeClass:
			case GBMethodTypeInstance:
				return [NSString stringWithFormat:@"%@[%@ %@]", self.methodPrefix, self.parentObject, self.methodSelector];
			case GBMethodTypeProperty:
				return [NSString stringWithFormat:@"%@%@.%@", self.methodPrefix, self.parentObject, self.methodSelector];
		}
	}
	return self.methodSelector;
}

#pragma mark Properties

@synthesize methodType = _methodType;
@synthesize methodAttributes = _methodAttributes;
@synthesize methodResultTypes = _methodResultTypes;
@synthesize methodArguments = _methodArguments;
@synthesize methodSelector = _methodSelector;
@synthesize methodSelectorDelimiter = _methodSelectorDelimiter;
@synthesize methodPrefix = _methodPrefix;
@synthesize isRequired;

@end
