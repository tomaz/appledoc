//
//  GBMethodsProvider.m
//  appledoc
//
//  Created by Tomaz Kragelj on 26.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBMethodData.h"
#import "GBMethodSectionData.h"
#import "GBMethodsProvider.h"
#import "GBTypedefBlockData.h"

@interface GBMethodsProvider ()

- (void)addMethod:(GBMethodData *)method toSortedArray:(NSMutableArray *)array;

@end

#pragma mark -

@implementation GBMethodsProvider
@synthesize useAlphabeticalOrder = _useAlphabeticalOrder;

#pragma mark Initialization & disposal

- (id)initWithParentObject:(id)parent {
    NSParameterAssert(parent != nil);
    GBLogDebug(@"Initializing methods provider for %@...", parent);
    self = [super init];
    if (self) {
        _parent = parent;
        _sections = [[NSMutableArray alloc] init];
        _methods = [[NSMutableArray alloc] init];
        _classMethods = [[NSMutableArray alloc] init];
        _instanceMethods = [[NSMutableArray alloc] init];
        _properties = [[NSMutableArray alloc] init];
        _methodsBySelectors = [[NSMutableDictionary alloc] init];
        _sectionsByNames = [[NSMutableDictionary alloc] init];
        _useAlphabeticalOrder = YES;
    }
    return self;
}

#pragma mark Registration methods

- (GBMethodSectionData *)registerSectionWithName:(NSString *)name {
	GBLogDebug(@"%@: Registering section %@...", _parent, name ? name : @"default");
	GBMethodSectionData *section = [[GBMethodSectionData alloc] init];
	section.sectionName = name;
	_registeringSection = section;
	[_sections addObject:section];
	if (name) [_sectionsByNames setObject:section forKey:name];
	return section;
}

- (GBMethodSectionData *)registerSectionIfNameIsValid:(NSString *)string {
	if (!string) return nil;
	string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if ([string length] == 0) return nil;
	if ([_sections count] > 0 && [[[_sections lastObject] sectionName] isEqualToString:string]) return nil;
	return [self registerSectionWithName:string];
}

- (void)unregisterEmptySections {
	GBLogDebug(@"Unregistering empty sections...");
	for (NSUInteger i=0; i<[_sections count]; i++) {
		GBMethodSectionData *section = [_sections objectAtIndex:i];
		if ([section.methods count] == 0) {
			[_sections removeObject:section];
			i--;
		}
	}
}

- (void)registerMethod:(GBMethodData *)method {
	// Note that we allow adding several methods with the same selector as long as the type is different (i.e. class and instance methods). In such case, methodBySelector will preffer instance method or property to class method! Note that this could be implemented more inteligently by prefixing selectors with some char or similar and then handling that within methodBySelector: and prefer instance/property in there. However at the time being current code seems sufficient and simpler, so let's stick with it for a while...
	NSParameterAssert(method != nil);
	GBLogDebug(@"%@: Registering method %@...", _parent, method);
	if ([_methods containsObject:method]) return;
	GBMethodData *existingMethod = [_methodsBySelectors objectForKey:method.methodSelector];
	if (existingMethod && existingMethod.methodType == method.methodType) {
		[existingMethod mergeDataFromObject:method];
		return;
	}
	
	method.parentObject = _parent;
	[_methods addObject:method];	
	if ([self.sections count] == 0) _registeringSection = [self registerSectionWithName:nil];
	if (!_registeringSection) _registeringSection = [self.sections lastObject];
	[_registeringSection registerMethod:method];
	
	switch (method.methodType) {
		case GBMethodTypeClass:
			[self addMethod:method toSortedArray:_classMethods];
			break;
		case GBMethodTypeInstance:
			[self addMethod:method toSortedArray:_instanceMethods];
			break;
		case GBMethodTypeProperty:
			[self addMethod:method toSortedArray:_properties];
			break;
	}
		
	// Register property getters and setters. Note that we always register setter even if it's just readonly property...
	if (method.isProperty) {
		NSString *getterSelector = method.propertyGetterSelector;
		if (![getterSelector isEqualToString:method.methodSelector]) [_methodsBySelectors setObject:method forKey:getterSelector];
		[_methodsBySelectors setObject:method forKey:method.propertySetterSelector];
	}

	// Register the selector so that we can handle existing methods later on. The first line prefers instance to class methods!
	if (existingMethod && existingMethod.methodType != GBMethodTypeClass) return;
	[_methodsBySelectors setObject:method forKey:method.methodSelector];
}

- (void)unregisterMethod:(GBMethodData *)method {
	// Remove from all our lists.
	[_methodsBySelectors removeObjectForKey:method.methodSelector];
	[_methods removeObject:method];
	[_classMethods removeObject:method];
	[_instanceMethods removeObject:method];
	[_properties removeObject:method];
	
	// Ask all sections to remove the method from their lists.
	[_sections enumerateObjectsUsingBlock:^(GBMethodSectionData *section, NSUInteger idx, BOOL *stop) {
		if ([section unregisterMethod:method]) {
			if ([section.methods count] == 0) {
				[_sections removeObject:section];
				if (section.sectionName) [_sectionsByNames removeObjectForKey:section.sectionName];
			}
			*stop = YES;
		}
	}];
}

- (void)addMethod:(GBMethodData *)method toSortedArray:(NSMutableArray *)array {
	[array addObject:method];
    if (_useAlphabeticalOrder) {
        [array sortUsingComparator:^(GBMethodData *obj1, GBMethodData *obj2) {
            return [obj1.methodSelector compare:obj2.methodSelector];
        }];
    }
}

#pragma mark Output generation helpers

- (BOOL)hasSections {
	return ([self.sections count] > 0);
}

- (BOOL)hasMultipleSections {
	return ([self.sections count] > 1);
}

- (BOOL)hasClassMethods {
	return ([self.classMethods count] > 0);
}

- (BOOL)hasInstanceMethods {
	return ([self.instanceMethods count] > 0);
}

- (BOOL)hasProperties {
	return ([self.properties count] > 0);
}

#pragma mark Helper methods

- (void)mergeDataFromMethodsProvider:(GBMethodsProvider *)source {
	// If a method with the same selector is found while merging from source, we should check if the type also matches. If so, we can merge the data from the source's method. However if the type doesn't match, we should ignore the method alltogether (ussually this is due to custom property implementation). We should probably deal with this scenario more inteligently, but it seems it works...
	if (!source || source == self) return;
	GBLogDebug(@"%@: Merging methods from %@...", _parent, source->_parent);
	
	// First merge all existing methods regardless of section and prepare the list of all new methods.
	NSMutableArray *newMethods = [NSMutableArray array];
	[source.methods enumerateObjectsUsingBlock:^(GBMethodData *sourceMethod, NSUInteger idx, BOOL *stop) {
		GBMethodData *existingMethod = [self methodBySelector:sourceMethod.methodSelector];
		if (!existingMethod) {
			[newMethods addObject:sourceMethod];
			return;
		}
		[existingMethod mergeDataFromObject:sourceMethod];
	}];
	if ([newMethods count] == 0) return;
	
	// Second merge all sections; only use sections for methods that were not registered yet! Note that we need to remember current section so that we restore it later on.
	__block GBMethodSectionData *unnamedSection = nil;
	GBMethodSectionData *previousSection = _registeringSection;
	[source.sections enumerateObjectsUsingBlock:^(GBMethodSectionData *sourceSection, NSUInteger idx, BOOL *stop) {
		[newMethods enumerateObjectsUsingBlock:^(GBMethodData *sourceMethod, NSUInteger idx, BOOL *stop) {
			if ([sourceSection.methods containsObject:sourceMethod]) {
				if (!sourceSection.sectionName) {
					if (!unnamedSection) unnamedSection = [self registerSectionWithName:nil];
					_registeringSection = unnamedSection;
				} else {
					_registeringSection = [_sectionsByNames objectForKey:sourceSection.sectionName];
					if (!_registeringSection) _registeringSection = [self registerSectionWithName:sourceSection.sectionName];
				}
				[self registerMethod:sourceMethod];
				return;
			}
		}];
	}];
	_registeringSection = previousSection;
}

- (GBMethodData *)methodBySelector:(NSString *)selector {
	return [_methodsBySelectors objectForKey:selector];
}

#pragma mark Overriden methods

- (NSString *)description {
	return [_parent description];
}

- (NSString *)debugDescription {
	NSMutableString *result = [NSMutableString string];
	[self.sections enumerateObjectsUsingBlock:^(GBMethodSectionData *section, NSUInteger idx, BOOL *stop) {
		[result appendFormat:@"- %@\n", section.sectionName];
		[section.methods enumerateObjectsUsingBlock:^(GBMethodData *method, NSUInteger idx, BOOL *stop) {
			[result appendFormat:@"  - %@\n", method.methodSelector];
		}];
	}];
	return result;
}

#pragma mark Properties

@synthesize methods = _methods;
@synthesize classMethods = _classMethods;
@synthesize instanceMethods = _instanceMethods;
@synthesize properties = _properties;
@synthesize sections = _sections;

@end
