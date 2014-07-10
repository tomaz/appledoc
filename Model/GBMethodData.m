//
//  GBMethodData.m
//  appledoc
//
//  Created by Tomaz Kragelj on 26.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GRMustache/GRMustache.h"
#import "GBMethodArgument.h"
#import "GBMethodSectionData.h"
#import "GBMethodData.h"
#import "GBClassData.h"
#import "GBCategoryData.h"
#import "RegexKitLite.h"

#import "GBStore.h"
#import "GBApplicationSettingsProvider.h"

@interface GBMethodData ()

- (NSString *)selectorFromAssignedData;
- (NSString *)prefixedSelectorFromAssignedData;
- (NSString *)selectorDelimiterFromAssignedData;
- (NSString *)prefixFromAssignedData;
- (BOOL)formatTypesFromArray:(NSArray *)types toArray:(NSMutableArray *)array prefix:(NSString *)prefix suffix:(NSString *)suffix;
- (NSDictionary *)formattedComponentWithValue:(NSString *)value;
- (NSDictionary *)formattedComponentWithValue:(NSString *)value style:(NSUInteger)style href:(NSString *)href;
- (NSString *)attributeValueForKey:(NSString *)key;
- (BOOL)validateMergeWith:(GBMethodData *)source;
@property (readonly) NSString *methodSelectorDelimiter;
@property (readonly) NSString *methodPrefix;


@end

#pragma mark -

@implementation GBMethodData

#pragma mark Initialization & disposal

+ (id)methodDataWithType:(GBMethodType)type result:(NSArray *)result arguments:(NSArray *)arguments {
	NSParameterAssert([arguments count] >= 1);
	return [[self alloc] initWithType:type attributes:[NSArray array] result:result arguments:arguments];
}

+ (id)propertyDataWithAttributes:(NSArray *)attributes components:(NSArray *)components {
	NSParameterAssert([components count] >= 2);	// At least one return and the name!
    
    // extract return type and property name
    NSString *propertyName = nil;
    NSMutableArray *results = [NSMutableArray array];
    BOOL nextComponentIsBlockPropertyName = NO;
    BOOL nextComponentIsBlockReturnComponent = NO;
	BOOL nextComponentIsPropertyName = NO;
    BOOL inProtocolsList = NO;
    NSUInteger parenthesisLevel = 0;
    for (NSString *component in components) {
        if ([component isEqualToString:@"^"]) {
            [results addObject:component];
            nextComponentIsBlockPropertyName = YES;
        } else if (nextComponentIsBlockPropertyName) {
            propertyName = component;
            nextComponentIsBlockPropertyName = NO;
            nextComponentIsBlockReturnComponent = YES;
        } else if (nextComponentIsBlockReturnComponent) {
            if (parenthesisLevel > 0 || [component isEqualToString:@"("]) {
                [results addObject:component];
            }
        } else if ([component isEqualToString:@"<"]) {
            inProtocolsList = YES;
            [results addObject:component];
        } else if ([component isEqualToString:@">"]) {
            inProtocolsList = NO;
            [results addObject:component];
		} else if ([component isEqualToString:@"*"]) {
			[results addObject:component];
			nextComponentIsPropertyName = YES;
		} else if ([component isEqualToString:@"id"]) {
			[results addObject:component];
        } else if ([component isMatchedByRegex:@"^[_a-zA-Z][_a-zA-Z0-9]$"]) {
			if (results.count == 0 || inProtocolsList) {
                [results addObject:component];
            } else if (propertyName == nil || nextComponentIsPropertyName) {
                propertyName = component;
				nextComponentIsPropertyName = NO;
            } else {
                // ignore termination macro
            }
        } else if (propertyName == nil) {
			if (nextComponentIsPropertyName) {
				propertyName = propertyName;
				nextComponentIsPropertyName = NO;
			} else {
				[results addObject:component];
			}
        }
        if ([component isEqualToString:@"("]) {
            ++parenthesisLevel;
        } else if ([component isEqualToString:@")"]) {
            --parenthesisLevel;
        }
    }
	
	// In case we end up with no property name, just take the last component...
	if (!propertyName) propertyName = [components lastObject];
	if ([results containsObject:propertyName]) [results removeObject:propertyName];
    
	GBMethodArgument *argument = [GBMethodArgument methodArgumentWithName:propertyName];
	return [[self alloc] initWithType:GBMethodTypeProperty attributes:attributes result:results arguments:[NSArray arrayWithObject:argument]];
}

- (id)initWithType:(GBMethodType)type attributes:(NSArray *)attributes result:(NSArray *)result arguments:(NSArray *)arguments {
	self = [super init];
	if (self) {
		_methodType = type;
		_methodAttributes = attributes;
		_methodResultTypes = result;
		_methodArguments = arguments;
		_methodPrefix = [self prefixFromAssignedData];
		_methodSelectorDelimiter = [self selectorDelimiterFromAssignedData];
		_methodSelector = [self selectorFromAssignedData];
        _methodReturnType = (NSString *)self.methodResultTypes.firstObject;
		_prefixedMethodSelector = [self prefixedSelectorFromAssignedData];
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
		if ([self.methodAttributes count] > 0) {
			__block BOOL isSetterOrGetter = NO;
            __block BOOL hasSetter = NO;
			[result addObject:[self formattedComponentWithValue:@"("]];
			[self.methodAttributes enumerateObjectsUsingBlock:^(NSString *attribute, NSUInteger idx, BOOL *stop) {
				if(hasSetter && [attribute isEqualToString:@":"]) //remove previously added "," and " " to keep clean setter=xxx:
                {
                    [result removeLastObject];
                    [result removeLastObject];
                    hasSetter = NO;
                }
                [result addObject:[self formattedComponentWithValue:attribute]];
				if ([attribute isEqualToString:@"setter"] || [attribute isEqualToString:@"getter"]) {
					isSetterOrGetter = YES;
                    if ([attribute isEqualToString:@"setter"]) {
                        hasSetter = YES;
                    }
					return;
				}
				if (isSetterOrGetter) {
					if ([attribute isEqualToString:@"="]) return;
					isSetterOrGetter = NO;
				}
				if (idx < [self.methodAttributes count]-1 ) {
					[result addObject:[self formattedComponentWithValue:@","]];
					[result addObject:[self formattedComponentWithValue:@" "]];
				}
			}];
			[result addObject:[self formattedComponentWithValue:@")"]];
			[result addObject:[self formattedComponentWithValue:@" "]];
		}
		
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
				if (argument.isVariableArg) {
					[result addObject:[self formattedComponentWithValue:@","]];
					[result addObject:[self formattedComponentWithValue:@" "]];
					[result addObject:[self formattedComponentWithValue:@"..." style:1 href:nil]];
				}
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
	__block BOOL insideProtocol = NO;
	__block BOOL appendSpace = NO;
	[types enumerateObjectsUsingBlock:^(NSString *type, NSUInteger idx, BOOL *stop) {
		if (appendSpace) [array addObject:[self formattedComponentWithValue:@" "]];
		[array addObject:[self formattedComponentWithValue:type]];
		
		// We should not add space after last element or after pointer.
		appendSpace = YES;
		BOOL isLast = (idx == [types count] - 1);
		BOOL isPointer = [type isEqualToString:@"*"];
		if (isLast || isPointer) appendSpace = NO;
		
		// We should not add space between components of a protocol (i.e. id<ProtocolName> should be written without any space). Because we've alreay
		if (!isLast && idx+1 < [types count] && [[types objectAtIndex:idx+1] isEqualToString:@"<"])
			insideProtocol = YES;
		else if ([type isEqualToString:@">"])
			insideProtocol = NO;
		if (insideProtocol) appendSpace = NO;
		
		lastCompWasPointer = isPointer;
	}];
	
	if (hasValues && suffix) [array addObject:[self formattedComponentWithValue:suffix]];
	return lastCompWasPointer;
}

- (NSDictionary *)formattedComponentWithValue:(NSString *)value {
    
    NSString *href = nil;
    id referencedObject = nil;
    if (!(referencedObject = [[GBStore sharedStore] classWithName: value])) {
        if (!(referencedObject = [[GBStore sharedStore] categoryWithName: value])) {
            if (!(referencedObject = [[GBStore sharedStore] protocolWithName: value])) {
                if (!(referencedObject = [[GBStore sharedStore] typedefEnumWithName: value])) {
                    if (!(referencedObject = [[GBStore sharedStore] typedefBlockWithName: value])) {
                        referencedObject = [[GBStore sharedStore] documentWithName: value];
                    }
                }
            }
        }
    }
    
    if (referencedObject != nil) {
        NSString *relPath = [[GBApplicationSettingsProvider sharedApplicationSettingsProvider] htmlRelativePathToIndexFromObject: self];
        NSString *linkPath = [[GBApplicationSettingsProvider sharedApplicationSettingsProvider] htmlReferenceForObject:referencedObject fromSource: nil];
        
        href = [relPath stringByAppendingPathComponent: linkPath];
    }
    
	return [self formattedComponentWithValue:value style:0 href:href];
}

- (NSDictionary *)formattedComponentWithValue:(NSString *)value style:(NSUInteger)style href:(NSString *)href {
	NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:3];
	[result setObject:value forKey:@"value"];
	if (style > 0) {
		[result setObject:[NSNumber numberWithUnsignedInt:style] forKey:@"style"];
		[result setObject:[NSNumber numberWithBool:YES] forKey:@"emphasized"];
	}
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

- (NSString *)prefixedSelectorFromAssignedData {
	NSMutableString *result = [NSMutableString string];
	if ([self.methodPrefix length] > 0) [result appendFormat:@"%@ ", self.methodPrefix];
	[result appendString:self.methodSelector];
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
		case GBMethodTypeProperty: return  @"@property";
	}
	return @"";
}

- (NSString *)propertyGetterSelector {
	if (self.methodType != GBMethodTypeProperty) return nil;
	NSString *result = [self attributeValueForKey:@"getter"];
	if (!result) result = self.methodSelector;
	return result;
}

- (NSString *)propertySetterSelector {
	if (self.methodType != GBMethodTypeProperty) return nil;
	NSString *result = [self attributeValueForKey:@"setter"];
	if (!result) {
		NSString *firstLetter = [[self.methodSelector substringToIndex:1] uppercaseString];
		NSString *theRest = [self.methodSelector substringFromIndex:1];
		result = [NSString stringWithFormat:@"set%@%@:", firstLetter, theRest];
	}
	return result;
}

- (NSString *)propertyType {
    if (self.methodType != GBMethodTypeProperty) return nil;
    NSString *result = (NSString *)self.methodResultTypes.firstObject;
    if (!result) result = self.methodReturnType;
    return result;
}

- (NSString *)attributeValueForKey:(NSString *)key {
	// Returns the value after equal sign for the given key (i.e. for attributes "getter", "=", "value", this would return "value"). Returns nil if either key isn't found or isn't followed by equal sign and/or a value.
	__block NSString *result = nil;
	__block BOOL foundKey = NO;
	[self.methodAttributes enumerateObjectsUsingBlock:^(NSString *attribute, NSUInteger idx, BOOL *stop) {
		if ([attribute isEqualToString:key]) {
			foundKey = YES;
			return;
		}
		if (foundKey && ![attribute isEqualToString:@"="]) {
			result = attribute;
			*stop = YES;
		}
	}];
	return result;
}

- (BOOL)validateMergeWith:(GBMethodData *)source {
	// Validates merging with the given method. This method raises exception if merging is not allowed based on method types. It takes into account manual propery accessors and mutators! Note that in case class method is being matched with instance, we prevent merging - this is to allow same selectors (due to how we currently handle class/instance methods (i.e. don't distinguish between them when matching by selectors) we simply need to prevent merging taking place in such case).
	if (source.methodType != self.methodType) {
		GBMethodData *propertyData = nil;
		GBMethodData *manualData = nil;
		if (self.methodType == GBMethodTypeProperty && source.methodType == GBMethodTypeInstance) {
			propertyData = self;
			manualData = source;
		} else if (self.methodType == GBMethodTypeInstance && source.methodType == GBMethodTypeProperty) {
			propertyData = source;
			manualData = self;
		} else if (self.methodType == GBMethodTypeInstance && source.methodType == GBMethodTypeClass) {
			return NO;
		} else if (self.methodType == GBMethodTypeClass && source.methodType == GBMethodTypeInstance) {
			return NO;
		} else if (self.methodType == GBMethodTypeProperty && source.methodType == GBMethodTypeClass) {
			return NO;
		} else {
			[NSException raise:@"Failed merging %@ to %@; method type doesn't match!", source, self];
		}
		
		// We should allow if the getter or setter matches and if the getter name is shared to an instance method.
		if ([propertyData.propertyGetterSelector isEqualToString:manualData.methodSelector]) return YES;
		if ([propertyData.propertySetterSelector isEqualToString:manualData.methodSelector]) return YES;
		if (![propertyData.propertyType isEqualToString:manualData.methodReturnType]) return YES;
        [NSException raise:@"Failed merging %@ to %@; getter or setter doesn't match", source, self];
	} else {
		// If assertion from code below is present, it breaks cases where category declares a property which is also getter for a property from class declaration. See #184 https://github.com/tomaz/appledoc/issues/184 for details. I'm leaving the code commented for the moment to see if it also affects some other user (don't think so, but just in case).
		//NSParameterAssert([source.methodSelector isEqualToString:self.methodSelector]);
	}
	return YES;
}

#pragma mark Overidden methods

- (void)mergeDataFromObject:(id)source {
	if (!source || source == self) return;
	GBLogDebug(@"%@: Merging data from %@...", self, source);
	if (![self validateMergeWith:source]) return;

	// Use argument var names from the method that has comment. If no method has comment, just keep deafult.
	if ([source comment] && ![self comment]) {
		GBLogDebug(@"%@: Checking for difference due to comment status...", self);
		for (NSUInteger i=0; i<[self.methodArguments count]; i++) {
			GBMethodArgument *ourArgument = [[self methodArguments] objectAtIndex:i];
			GBMethodArgument *otherArgument = [[source methodArguments] objectAtIndex:i];
			if (![ourArgument.argumentVar isEqualToString:otherArgument.argumentVar]) {
				GBLogDebug(@"%@: Changing %ld. argument var name from %@ to %@...", self, i+1, ourArgument.argumentVar, otherArgument.argumentVar);
				ourArgument.argumentVar = otherArgument.argumentVar;
			}
		}
	}
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

- (NSString *)methodTypeString {
    BOOL isInterfaceParent = (![self.parentObject isKindOfClass:[GBClassData class]] &&
                              ![self.parentObject isKindOfClass:[GBCategoryData class]]);
    switch (self.methodType)
    {
        case GBMethodTypeClass:
            return isInterfaceParent ? @"intfcm" : @"clm";
        case GBMethodTypeInstance:
            return isInterfaceParent ? @"intfm" : @"instm";
        case GBMethodTypeProperty:
            return isInterfaceParent ? @"intfp" : @"instp";
    }
    return @"";
}

- (BOOL)isInstanceMethod {
	return (self.methodType == GBMethodTypeInstance);
}

- (BOOL)isClassMethod {
	return (self.methodType == GBMethodTypeClass);
}

- (BOOL)isMethod {
	return !self.isProperty;
}

- (BOOL)isProperty {
	return (self.methodType == GBMethodTypeProperty);
}

@synthesize methodType = _methodType;
@synthesize methodAttributes = _methodAttributes;
@synthesize methodResultTypes = _methodResultTypes;
@synthesize methodArguments = _methodArguments;
@synthesize methodSelector = _methodSelector;
@synthesize methodReturnType = _methodReturnType;
@synthesize methodSelectorDelimiter = _methodSelectorDelimiter;
@synthesize methodPrefix = _methodPrefix;
@synthesize prefixedMethodSelector = _prefixedMethodSelector;
@synthesize methodSection;
@synthesize isRequired;

@end
