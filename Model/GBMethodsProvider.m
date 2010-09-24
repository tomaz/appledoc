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

@implementation GBMethodsProvider

#pragma mark Initialization & disposal

- (id)initWithParentObject:(id)parent {
	NSParameterAssert(parent != nil);
	GBLogDebug(@"Initializing methods provider for %@...", parent);
	self = [super init];
	if (self) {
		_parent = [parent retain];
		_sections = [[NSMutableArray alloc] init];
		_methods = [[NSMutableArray alloc] init];
		_methodsBySelectors = [[NSMutableDictionary alloc] init];
	}
	return self;
}

#pragma mark Registration methods

- (GBMethodSectionData *)registerSectionWithName:(NSString *)name {
	GBLogDebug(@"%@: Registering section %@...", _parent, name);
	GBMethodSectionData *section = [[[GBMethodSectionData alloc] init] autorelease];
	section.sectionName = name;
	[_sections addObject:section];
	return section;
}

- (GBMethodSectionData *)registerSectionIfNameIsValid:(NSString *)string {
	if (!string) return nil;
	string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if ([string length] == 0) return nil;
	return [self registerSectionWithName:string];
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
	if ([self.sections count] == 0) [self registerSectionWithName:nil];
	[[self.sections lastObject] registerMethod:method];
	
	if (existingMethod && existingMethod.methodType != GBMethodTypeClass) return;
	[_methodsBySelectors setObject:method forKey:method.methodSelector];
}

#pragma mark Helper methods

- (void)mergeDataFromMethodsProvider:(GBMethodsProvider *)source {
	// If a method with the same selector is found while merging from source, we should check if the type also matches. If so, we can merge the data from the source's method. However if the type doesn't match, we should ignore the method alltogether (ussually this is due to custom property implementation). We should probably deal with this scenario more inteligently, but it seems it works...
	if (!source || source == self) return;
	GBLogDebug(@"%@: Merging methods from %@...", _parent, source->_parent);
	for (GBMethodData *sourceMethod in source.methods) {
		GBMethodData *existingMethod = [_methodsBySelectors objectForKey:sourceMethod.methodSelector];
		if (existingMethod) {
			if (existingMethod.methodType == sourceMethod.methodType) [existingMethod mergeDataFromObject:sourceMethod];
			continue;
		}
		[self registerMethod:sourceMethod];
	}
}

- (GBMethodData *)methodBySelector:(NSString *)selector {
	return [_methodsBySelectors objectForKey:selector];
}

#pragma mark Properties

@synthesize methods = _methods;
@synthesize sections = _sections;

@end
