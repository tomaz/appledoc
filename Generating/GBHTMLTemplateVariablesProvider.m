//
//  GBHTMLTemplateVariablesProvider.m
//  appledoc
//
//  Created by Tomaz Kragelj on 1.10.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GRMustache.h"
#import "GBApplicationSettingsProviding.h"
#import "GBObjectDataProviding.h"
#import "GBStoreProviding.h"
#import "GBDataObjects.h"
#import "GBHTMLTemplateVariablesProvider.h"

#pragma mark -

@interface GBHTMLTemplateVariablesProvider ()

- (NSString *)hrefForObject:(id)object fromObject:(id)source;
- (NSDictionary *)arrayDescriptorForArray:(NSArray *)array;
- (void)addFooterVarsToDictionary:(NSMutableDictionary *)dict;
@property (readonly) NSDateFormatter *yearDateFormatter;
@property (readonly) NSDateFormatter *yearToDayDateFormatter;
@property (retain) id<GBApplicationSettingsProviding> settings;
@property (retain) id<GBStoreProviding> store;

@end

#pragma mark -

@interface GBHTMLTemplateVariablesProvider (ObjectVariables)

- (NSString *)pageTitleForClass:(GBClassData *)object;
- (NSString *)pageTitleForCategory:(GBCategoryData *)object;
- (NSString *)pageTitleForProtocol:(GBProtocolData *)object;
- (NSDictionary *)specificationsForClass:(GBClassData *)object;
- (NSDictionary *)specificationsForCategory:(GBCategoryData *)object;
- (NSDictionary *)specificationsForProtocol:(GBProtocolData *)object;

@end

#pragma mark -

@interface GBHTMLTemplateVariablesProvider (ObjectSpecifications)

- (void)registerObjectInheritsFromSpecificationForClass:(GBClassData *)class toArray:(NSMutableArray *)array;
- (void)registerObjectConformsToSpecificationForProvider:(id<GBObjectDataProviding>)provider toArray:(NSMutableArray *)array;
- (void)registerObjectDeclaredInSpecificationForProvider:(GBModelBase *)provider toArray:(NSMutableArray *)array;

- (NSDictionary *)objectSpecificationWithValues:(NSArray *)values title:(NSString *)title;
- (NSDictionary *)objectSpecificationValueWithData:(id)data href:(NSString *)href;
- (NSArray *)delimitObjectSpecificationValues:(NSArray *)values withDelimiter:(NSString *)delimiter;

@end

#pragma mark -

@interface GBHTMLTemplateVariablesProvider (IndexVariables)

- (NSString *)pageTitleForIndex;
- (NSArray *)classesForIndex;
- (NSArray *)categoriesForIndex;
- (NSArray *)protocolsForIndex;
- (void)registerObjectsUsageForIndexInDictionary:(NSMutableDictionary *)dict;

@end

#pragma mark -

@implementation GBHTMLTemplateVariablesProvider

#pragma mark Initialization & disposal

+ (id)providerWithSettingsProvider:(id)settingsProvider {
	return [[[self alloc] initWithSettingsProvider:settingsProvider] autorelease];
}

- (id)initWithSettingsProvider:(id)settingsProvider {
	NSParameterAssert(settingsProvider != nil);
	NSParameterAssert([settingsProvider conformsToProtocol:@protocol(GBApplicationSettingsProviding)]);
	GBLogDebug(@"Initializing variables provider with settings provider %@...", settingsProvider);
	self = [super init];
	if (self) {
		self.settings = settingsProvider;
	}
	return self;
}

#pragma mark Object variables handling

- (NSDictionary *)variablesForClass:(GBClassData *)object withStore:(id<GBStoreProviding>)store {
	self.store = store;
	NSMutableDictionary *page = [NSMutableDictionary dictionary];
	[page setObject:[self pageTitleForClass:object] forKey:@"title"];
	[page setObject:[self specificationsForClass:object] forKey:@"specifications"];
	[self addFooterVarsToDictionary:page];
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	[result setObject:page forKey:@"page"];
	[result setObject:object forKey:@"object"];
	[result setObject:self.settings.stringTemplates forKey:@"strings"];
	return result;
}

- (NSDictionary *)variablesForCategory:(GBCategoryData *)object withStore:(id<GBStoreProviding>)store {
	self.store = store;
	NSMutableDictionary *page = [NSMutableDictionary dictionary];
	[page setObject:[self pageTitleForCategory:object] forKey:@"title"];
	[page setObject:[self specificationsForCategory:object] forKey:@"specifications"];
	[self addFooterVarsToDictionary:page];
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	[result setObject:page forKey:@"page"];
	[result setObject:object forKey:@"object"];
	[result setObject:self.settings.stringTemplates forKey:@"strings"];
	return result;
}

- (NSDictionary *)variablesForProtocol:(GBProtocolData *)object withStore:(id<GBStoreProviding>)store {
	self.store = store;
	NSMutableDictionary *page = [NSMutableDictionary dictionary];
	[page setObject:[self pageTitleForProtocol:object] forKey:@"title"];
	[page setObject:[self specificationsForProtocol:object] forKey:@"specifications"];
	[self addFooterVarsToDictionary:page];
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	[result setObject:page forKey:@"page"];
	[result setObject:object forKey:@"object"];
	[result setObject:self.settings.stringTemplates forKey:@"strings"];
	return result;
}

#pragma mark Index variables handling

- (NSDictionary *)variablesForIndexWithStore:(id<GBStoreProviding>)store {
	self.store = store;
	NSMutableDictionary *page = [NSMutableDictionary dictionary];
	[page setObject:[self pageTitleForIndex] forKey:@"title"];
	[self addFooterVarsToDictionary:page];
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	[result setObject:page forKey:@"page"];
	[result setObject:[self classesForIndex] forKey:@"classes"];
	[result setObject:[self protocolsForIndex] forKey:@"protocols"];
	[result setObject:[self categoriesForIndex] forKey:@"categories"];
	[result setObject:self.settings.stringTemplates forKey:@"strings"];
	[self registerObjectsUsageForIndexInDictionary:result];
	return result;
}

#pragma mark Helper methods

- (NSString *)hrefForObject:(id)object fromObject:(id)source {
	if (!object) return nil;
	if ([object isKindOfClass:[GBClassData class]] && ![[self.store classes] containsObject:object]) return nil;
	if ([object isKindOfClass:[GBCategoryData class]] && ![[self.store categories] containsObject:object]) return nil;
	if ([object isKindOfClass:[GBProtocolData class]] && ![[self.store protocols] containsObject:object]) return nil;
	return [self.settings htmlReferenceForObject:object fromSource:source];
}

- (NSDictionary *)arrayDescriptorForArray:(NSArray *)array {
	// Helps handling arrays in template by embedding two keys: "used" as boolean and "items" as the actual array (only if non-empty).
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	if ([array count] > 0) {
		[result setObject:[GRYes yes] forKey:@"used"];
		[result setObject:array forKey:@"values"];
		return result;
	}
	[result setObject:[GRNo no] forKey:@"used"];
	return result;
}

#pragma mark Common values

- (void)addFooterVarsToDictionary:(NSMutableDictionary *)dict {
	[dict setObject:self.settings.projectCompany forKey:@"copyrightHolder"];
	[dict setObject:[self.yearDateFormatter stringFromDate:[NSDate date]] forKey:@"copyrightDate"];
	[dict setObject:[self.yearToDayDateFormatter stringFromDate:[NSDate date]] forKey:@"lastUpdatedDate"];
}

- (NSDateFormatter *)yearDateFormatter {
	static NSDateFormatter *result = nil;
	if (!result) {
		result = [[NSDateFormatter alloc] init];
		[result setDateFormat:@"yyyy"];
	}
	return result;
}

- (NSDateFormatter *)yearToDayDateFormatter {
	static NSDateFormatter *result = nil;
	if (!result) {
		result = [[NSDateFormatter alloc] init];
		[result setDateFormat:@"yyyy-MM-dd"];
	}
	return result;
}

#pragma mark Properties

@synthesize settings;
@synthesize store;

@end

#pragma mark -

@implementation GBHTMLTemplateVariablesProvider (ObjectVariables)

- (NSString *)pageTitleForClass:(GBClassData *)object {
	NSString *template = [self.settings.stringTemplates valueForKeyPath:@"objectPage.classTitle"];
	return [NSString stringWithFormat:template, object.nameOfClass];
}

- (NSString *)pageTitleForCategory:(GBCategoryData *)object {
	NSString *template = [self.settings.stringTemplates valueForKeyPath:@"objectPage.categoryTitle"];
	NSString *category = ([object.nameOfCategory length] > 0) ? object.nameOfCategory : @"";
	return [NSString stringWithFormat:template, object.nameOfClass, category];
}

- (NSString *)pageTitleForProtocol:(GBProtocolData *)object {
	NSString *template = [self.settings.stringTemplates valueForKeyPath:@"objectPage.protocolTitle"];
	return [NSString stringWithFormat:template, object.nameOfProtocol];
}

- (NSDictionary *)specificationsForClass:(GBClassData *)object {
	NSMutableArray *result = [NSMutableArray array];
	[self registerObjectInheritsFromSpecificationForClass:object toArray:result];
	[self registerObjectConformsToSpecificationForProvider:object toArray:result];
	[self registerObjectDeclaredInSpecificationForProvider:object toArray:result];
	return [self arrayDescriptorForArray:result];
}

- (NSDictionary *)specificationsForCategory:(GBCategoryData *)object {
	NSMutableArray *result = [NSMutableArray array];
	[self registerObjectConformsToSpecificationForProvider:object toArray:result];
	[self registerObjectDeclaredInSpecificationForProvider:object toArray:result];
	return [self arrayDescriptorForArray:result];
}

- (NSDictionary *)specificationsForProtocol:(GBProtocolData *)object {
	NSMutableArray *result = [NSMutableArray array];
	[self registerObjectConformsToSpecificationForProvider:object toArray:result];
	[self registerObjectDeclaredInSpecificationForProvider:object toArray:result];
	return [self arrayDescriptorForArray:result];
}

@end

#pragma mark -

@implementation GBHTMLTemplateVariablesProvider (ObjectSpecifications)

#pragma mark Specific specifications handling

- (void)registerObjectInheritsFromSpecificationForClass:(GBClassData *)class toArray:(NSMutableArray *)array {
	// Prepares inherits from specification with complete superclass hierarchy values for the given class and adds it to the end of the given array. If the class doesn't have superclass, nothing happens.
	if (!class.nameOfSuperclass) return;
	NSMutableArray *superclasses = [NSMutableArray array];
	GBClassData *itor = class;
	while (itor) {
		NSString *name = itor.nameOfSuperclass;
		NSString *href = [self hrefForObject:itor.superclass fromObject:class];
		if (!name) break;
		NSDictionary *data = [self objectSpecificationValueWithData:name href:href];
		[superclasses addObject:data];
		itor = itor.superclass;
	}
	NSArray *values = [self delimitObjectSpecificationValues:superclasses withDelimiter:@" : "];
	NSString *title = [self.settings.stringTemplates valueForKeyPath:@"objectSpecifications.inheritsFrom"];
	NSDictionary *data = [self objectSpecificationWithValues:values title:title];
	[array addObject:data];
}

- (void)registerObjectConformsToSpecificationForProvider:(id<GBObjectDataProviding>)provider toArray:(NSMutableArray *)array {
	// Prepares conforms to specification with all protocols the class conforms to for the given provider and adds it to the end of the given array. If the object doesn't conform to any protocol, nothing happens.
	if ([provider.adoptedProtocols.protocols count] == 0) return;
	NSMutableArray *protocols = [NSMutableArray arrayWithCapacity:[provider.adoptedProtocols.protocols count]];
	NSArray *adoptedProtocols = [provider.adoptedProtocols protocolsSortedByName];
	[adoptedProtocols enumerateObjectsUsingBlock:^(GBProtocolData *protocol, NSUInteger idx, BOOL *stop) {
		NSString *name = protocol.nameOfProtocol;
		NSString *href = [self hrefForObject:protocol fromObject:provider];
		NSDictionary *data = [self objectSpecificationValueWithData:name href:href];
		[protocols addObject:data];
	}];
	NSArray *values = [self delimitObjectSpecificationValues:protocols withDelimiter:@"<br />"];
	NSString *title = [self.settings.stringTemplates valueForKeyPath:@"objectSpecifications.conformsTo"];
	NSDictionary *data = [self objectSpecificationWithValues:values title:title];
	[array addObject:data];
}

- (void)registerObjectDeclaredInSpecificationForProvider:(GBModelBase *)provider toArray:(NSMutableArray *)array {
	// Prepares declared in specification with all source files the given object is declared in and adds it to the end of the given array. If the object doesn't contain any source information, nothing happens.
	if ([provider.sourceInfos count] == 0) return;
	NSMutableArray *specifications = [NSMutableArray arrayWithCapacity:[provider.sourceInfos count]];
	NSArray *infos = [provider sourceInfosSortedByName];
	[infos enumerateObjectsUsingBlock:^(GBSourceInfo *info, NSUInteger idx, BOOL *stop) {
		NSString *name = info.filename;
		NSDictionary *data = [self objectSpecificationValueWithData:name href:nil];
		[specifications addObject:data];
	}];
	NSArray *values = [self delimitObjectSpecificationValues:specifications withDelimiter:@"<br />"];
	NSString *title = [self.settings.stringTemplates valueForKeyPath:@"objectSpecifications.declaredIn"];
	NSDictionary *data = [self objectSpecificationWithValues:values title:title];
	[array addObject:data];
}

#pragma mark Common methods

- (NSDictionary *)objectSpecificationWithValues:(NSArray *)values title:(NSString *)title {
	// Prepares inherits from specification variable with the given array of superclass hierarchy values.
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	[result setObject:title forKey:@"title"];
	[result setObject:values forKey:@"values"];
	return result;
}

- (NSDictionary *)objectSpecificationValueWithData:(id)data href:(NSString *)href {
	// Prepares single specification value.
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	if (href) [result setObject:href forKey:@"href"];
	[result setObject:data forKey:@"string"];
	[result setObject:@"" forKey:@"delimiter"];
	return result;
}

- (NSArray *)delimitObjectSpecificationValues:(NSArray *)values withDelimiter:(NSString *)delimiter {
	// The array should contain mutable dictionaries with keys "data" and "href". We simplt add the delimiter to all but last value and use it to prepare the resulting specification dictionary containing all values.
	[values enumerateObjectsUsingBlock:^(NSMutableDictionary *data, NSUInteger idx, BOOL *stop) {
		if (idx < [values count] - 1) [data setObject:delimiter forKey:@"delimiter"];
	}];
	return values;
}

@end

#pragma mark -

@implementation GBHTMLTemplateVariablesProvider (IndexVariables)

- (NSString *)pageTitleForIndex {
	return [NSString stringWithFormat:@"%@ Reference", self.settings.projectName];
}

- (NSArray *)classesForIndex {
	NSArray *classes = [self.store classesSortedByName];
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:[classes count]];
	for (GBClassData *class in classes) {
		NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:2];
		[data setObject:[self hrefForObject:class fromObject:nil] forKey:@"href"];
		[data setObject:class.nameOfClass forKey:@"title"];
		[result addObject:data];
	}
	return result;
}

- (NSArray *)categoriesForIndex {
	NSArray *categories = [self.store categoriesSortedByName];
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:[categories count]];
	for (GBCategoryData *category in categories) {
		NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:2];
		[data setObject:[self hrefForObject:category fromObject:nil] forKey:@"href"];
		[data setObject:category.idOfCategory forKey:@"title"];
		[result addObject:data];
	}
	return result;
}

- (NSArray *)protocolsForIndex {
	NSArray *protocols = [self.store protocolsSortedByName];
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:[protocols count]];
	for (GBProtocolData *protocol in protocols) {
		NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:2];
		[data setObject:[self hrefForObject:protocol fromObject:nil] forKey:@"href"];
		[data setObject:protocol.nameOfProtocol forKey:@"title"];
		[result addObject:data];
	}
	return result;
}

- (void)registerObjectsUsageForIndexInDictionary:(NSMutableDictionary *)dict {
	BOOL classes = [self.store.classes count] > 0;
	BOOL categories = [self.store.categories count] > 0;
	BOOL protocols = [self.store.protocols count] > 0; 
	[dict setObject:classes ? [GRYes yes] : [GRNo no] forKey:@"hasClasses"];
	[dict setObject:categories ? [GRYes yes] : [GRNo no] forKey:@"hasCategories"];
	[dict setObject:protocols ? [GRYes yes] : [GRNo no] forKey:@"hasProtocols"];
	[dict setObject:(protocols || categories) ? [GRYes yes] : [GRNo no] forKey:@"hasProtocolsOrCategories"];
}

@end
