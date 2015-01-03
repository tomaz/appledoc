//
//  GBHTMLTemplateVariablesProvider.m
//  appledoc
//
//  Created by Tomaz Kragelj on 1.10.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "RegexKitLite.h"
#import "GRMustache/GRMustache.h"
#import "GBStore.h"
#import "GBApplicationSettingsProvider.h"
#import "GBObjectDataProviding.h"
#import "GBDataObjects.h"
#import "GBDocumentData.h"
#import "GBHTMLTemplateVariablesProvider.h"

#pragma mark -

@interface GBHTMLTemplateVariablesProvider ()

- (NSString *)hrefForObject:(id)object fromObject:(id)source;
- (NSDictionary *)arrayDescriptorForArray:(NSArray *)array;
- (void)addCustomDocumentWithKey:(id)key toDictionary:(NSMutableDictionary *)dict key:(id)dictKey;
- (void)addFooterVarsToDictionary:(NSMutableDictionary *)dict;
@property (strong) GBStore *store;
@property (strong) GBApplicationSettingsProvider *settings;

@end

#pragma mark -

@interface GBHTMLTemplateVariablesProvider (ObjectVariables)

- (NSString *)pageTitleForClass:(GBClassData *)object;
- (NSString *)pageTitleForCategory:(GBCategoryData *)object;
- (NSString *)pageTitleForProtocol:(GBProtocolData *)object;
- (NSString *)pageTitleForDocument:(GBDocumentData *)object;
- (NSString *)pageTitleForConstant:(GBTypedefEnumData *)object;
- (NSString *)pageTitleForBlock:(GBTypedefBlockData *)object;
- (NSDictionary *)specificationsForClass:(GBClassData *)object;
- (NSDictionary *)specificationsForCategory:(GBCategoryData *)object;
- (NSDictionary *)specificationsForProtocol:(GBProtocolData *)object;
- (NSDictionary *)specificationsForConstant:(GBTypedefEnumData *)object;
- (NSDictionary *)specificationsForBlock:(GBTypedefBlockData *)object;

@end

#pragma mark -

@interface GBHTMLTemplateVariablesProvider (ObjectSpecifications)

- (void)registerObjectInheritsFromSpecificationForClass:(GBClassData *)class toArray:(NSMutableArray *)array;
- (void)registerObjectConformsToSpecificationForProvider:(id<GBObjectDataProviding>)provider toArray:(NSMutableArray *)array;
- (void)registerObjectDeclaredInSpecificationForProvider:(GBModelBase *)provider toArray:(NSMutableArray *)array;
- (void)registerObjectCompanionGuidesSpecificationForObject:(GBModelBase *)object toArray:(NSMutableArray *)array;
- (void)registerObjectAvailabilitySpecificationForProvider:(GBModelBase *)object toArray:(NSMutableArray *)array;
- (void)registerObjectReferenceSpecificationForProvider:(GBModelBase *)object toArray:(NSMutableArray *)array;

- (NSDictionary *)objectSpecificationWithValues:(NSArray *)values title:(NSString *)title;
- (NSDictionary *)objectSpecificationValueWithData:(id)data href:(NSString *)href;
- (NSArray *)delimitObjectSpecificationValues:(NSArray *)values withDelimiter:(NSString *)delimiter;

@end

#pragma mark -

@interface GBHTMLTemplateVariablesProvider (IndexVariables)

- (NSString *)pageTitleForIndex;
- (NSString *)pageTitleForHierarchy;
- (NSArray *)documentsForIndex;
- (NSArray *)classesForIndex;
- (NSArray *)categoriesForIndex;
- (NSArray *)protocolsForIndex;
- (NSArray *)classesForHierarchy;
- (NSArray *)constantsForIndex;
- (NSArray *)blocksForIndex;
- (NSArray *)arrayFromHierarchyLevel:(NSDictionary *)level;
- (void)registerObjectsUsageForIndexInDictionary:(NSMutableDictionary *)dict;

@end

#pragma mark -

@implementation GBHTMLTemplateVariablesProvider

#pragma mark Initialization & disposal

+ (id)providerWithSettingsProvider:(id)settingsProvider {
	return [[self alloc] initWithSettingsProvider:settingsProvider];
}

- (id)initWithSettingsProvider:(id)settingsProvider {
	NSParameterAssert(settingsProvider != nil);
	GBLogDebug(@"Initializing variables provider with settings provider %@...", settingsProvider);
	self = [super init];
	if (self) {
		self.settings = settingsProvider;
	}
	return self;
}

#pragma mark Object variables handling

- (NSDictionary *)variablesForClass:(GBClassData *)object withStore:(id)aStore {
	self.store = aStore;
	NSMutableDictionary *page = [NSMutableDictionary dictionary];
	[page setObject:[self pageTitleForClass:object] forKey:@"title"];
	[page setObject:[self specificationsForClass:object] forKey:@"specifications"];
	[self addFooterVarsToDictionary:page];
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	[result setObject:page forKey:@"page"];
	[result setObject:object forKey:@"object"];
	[result setObject:self.settings.projectCompany forKey:@"projectCompany"];
	[result setObject:self.settings.projectName forKey:@"projectName"];
	[result setObject:self.settings.stringTemplates forKey:@"strings"];
	return result;
}

- (NSDictionary *)variablesForCategory:(GBCategoryData *)object withStore:(id)aStore {
	self.store = aStore;
	NSMutableDictionary *page = [NSMutableDictionary dictionary];
	[page setObject:[self pageTitleForCategory:object] forKey:@"title"];
	[page setObject:[self specificationsForCategory:object] forKey:@"specifications"];
	[self addFooterVarsToDictionary:page];
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	[result setObject:page forKey:@"page"];
	[result setObject:object forKey:@"object"];
	[result setObject:self.settings.projectCompany forKey:@"projectCompany"];
	[result setObject:self.settings.projectName forKey:@"projectName"];
	
	[result setObject:self.settings.stringTemplates forKey:@"strings"];
	return result;
}

- (NSDictionary *)variablesForProtocol:(GBProtocolData *)object withStore:(id)aStore {
	self.store = aStore;
	NSMutableDictionary *page = [NSMutableDictionary dictionary];
	[page setObject:[self pageTitleForProtocol:object] forKey:@"title"];
	[page setObject:[self specificationsForProtocol:object] forKey:@"specifications"];
	[self addFooterVarsToDictionary:page];
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	[result setObject:page forKey:@"page"];
	[result setObject:object forKey:@"object"];
	[result setObject:self.settings.projectCompany forKey:@"projectCompany"];
	[result setObject:self.settings.projectName forKey:@"projectName"];
	[result setObject:self.settings.stringTemplates forKey:@"strings"];
	return result;
}

- (NSDictionary *)variablesForConstant:(GBTypedefEnumData *)typedefEnum withStore:(id)aStore {
	self.store = aStore;
	NSMutableDictionary *page = [NSMutableDictionary dictionary];
	[page setObject:[self pageTitleForConstant:typedefEnum] forKey:@"title"];
	[page setObject:[self specificationsForConstant:typedefEnum] forKey:@"specifications"];
	[self addFooterVarsToDictionary:page];
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	[result setObject:page forKey:@"page"];
	[result setObject:typedefEnum forKey:@"typedefEnum"];
	[result setObject:self.settings.projectCompany forKey:@"projectCompany"];
	[result setObject:self.settings.projectName forKey:@"projectName"];
	[result setObject:self.settings.stringTemplates forKey:@"strings"];
	return result;
}

- (NSDictionary *)variablesForBlocks:(GBTypedefBlockData *)typedefBlock withStore:(id)aStore {
    self.store = aStore;
    NSMutableDictionary *page = [NSMutableDictionary dictionary];
    [page setObject:[self pageTitleForBlock:typedefBlock] forKey:@"title"];
    [page setObject:[self specificationsForBlock:typedefBlock] forKey:@"specifications"];
    [self addFooterVarsToDictionary:page];
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [result setObject:page forKey:@"page"];
    [result setObject:typedefBlock forKey:@"typedefBlock"];
    [result setObject:self.settings.projectCompany forKey:@"projectCompany"];
    [result setObject:self.settings.projectName forKey:@"projectName"];
    [result setObject:self.settings.stringTemplates forKey:@"strings"];
    return result;
}


- (NSDictionary *)variablesForDocument:(GBDocumentData *)object withStore:(id)aStore {
	self.store = aStore;
	NSString *path = [self.settings htmlRelativePathToIndexFromObject:object];
	NSMutableDictionary *page = [NSMutableDictionary dictionary];
	[page setObject:[self pageTitleForDocument:object] forKey:@"title"];
	[page setObject:[path stringByAppendingPathComponent:@"css/styles.css"] forKey:@"cssPath"];
	[page setObject:[path stringByAppendingPathComponent:@"css/stylesPrint.css"] forKey:@"cssPrintPath"];
    [page setObject:[path stringByAppendingPathComponent:@"index.html"] forKey:@"documentationIndexPath"];
	[self addFooterVarsToDictionary:page];
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	[result setObject:page forKey:@"page"];
	[result setObject:object forKey:@"object"];
	[result setObject:self.settings.projectCompany forKey:@"projectCompany"];
	[result setObject:self.settings.projectName forKey:@"projectName"];
	[result setObject:self.settings.stringTemplates forKey:@"strings"];
	[self addFooterVarsToDictionary:result];
	return result;
}

#pragma mark Index variables handling

- (NSDictionary *)variablesForIndexWithStore:(id)aStore {
	self.store = aStore;
	NSMutableDictionary *page = [NSMutableDictionary dictionary];
	[page setObject:[self pageTitleForIndex] forKey:@"title"];
	[self addFooterVarsToDictionary:page];
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	[result setObject:page forKey:@"page"];
	[result setObject:[self documentsForIndex] forKey:@"docs"];
	[result setObject:[self classesForIndex] forKey:@"classes"];
	[result setObject:[self protocolsForIndex] forKey:@"protocols"];
	[result setObject:[self categoriesForIndex] forKey:@"categories"];
    [result setObject:[self constantsForIndex]  forKey:@"constants"];
    [result setObject:[self blocksForIndex]  forKey:@"blocks"];
	[result setObject:self.settings.stringTemplates forKey:@"strings"];
	[result setObject:self.settings.projectCompany forKey:@"projectCompany"];
	[result setObject:self.settings.projectName forKey:@"projectName"];
	
	[self addCustomDocumentWithKey:kGBCustomDocumentIndexDescKey toDictionary:result key:@"indexDescription"];
	[self registerObjectsUsageForIndexInDictionary:result];
	return result;
}

- (NSDictionary *)variablesForHierarchyWithStore:(id)aStore {
	self.store = aStore;
	NSMutableDictionary *page = [NSMutableDictionary dictionary];
	[page setObject:[self pageTitleForHierarchy] forKey:@"title"];
	[self addFooterVarsToDictionary:page];
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	[result setObject:page forKey:@"page"];
	[result setObject:[self classesForHierarchy] forKey:@"classes"];
	[result setObject:[self protocolsForIndex] forKey:@"protocols"];
	[result setObject:[self categoriesForIndex] forKey:@"categories"];
	[result setObject:[self constantsForIndex] forKey:@"constants"];
    [result setObject:[self blocksForIndex] forKey:@"blocks"];
    [result setObject:self.settings.stringTemplates forKey:@"strings"];
	[result setObject:self.settings.projectCompany forKey:@"projectCompany"];
	[result setObject:self.settings.projectName forKey:@"projectName"];
	
	[self registerObjectsUsageForIndexInDictionary:result];
	return result;
}

#pragma mark Helper methods

- (NSString *)hrefForObject:(id)object fromObject:(id)source {
	if (!object) return nil;
	if ([object isKindOfClass:[GBClassData class]] && ![[self.store classes] containsObject:object]) return nil;
	if ([object isKindOfClass:[GBCategoryData class]] && ![[self.store categories] containsObject:object]) return nil;
	if ([object isKindOfClass:[GBProtocolData class]] && ![[self.store protocols] containsObject:object]) return nil;
	if ([object isKindOfClass:[GBDocumentData class]] && ![[self.store documents] containsObject:object]) return nil;
	if ([object isKindOfClass:[GBTypedefEnumData class]] && ![[self.store constants] containsObject:object]) return nil;
    if ([object isKindOfClass:[GBTypedefBlockData class]] && ![[self.store blocks] containsObject:object]) return nil;
	return [self.settings htmlReferenceForObject:object fromSource:source];
}

- (NSDictionary *)arrayDescriptorForArray:(NSArray *)array {
	// Helps handling arrays in template by embedding two keys: "used" as boolean and "items" as the actual array (only if non-empty).
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	if ([array count] > 0) {
		[result setObject:[NSNumber numberWithBool:YES] forKey:@"used"];
		[result setObject:array forKey:@"values"];
		return result;
	}
	[result setObject:[NSNumber numberWithBool:NO] forKey:@"used"];
	return result;
}

#pragma mark Common values

- (void)addCustomDocumentWithKey:(id)key toDictionary:(NSMutableDictionary *)dict key:(id)dictKey {
	// Adds custom document with the given key to the given dictionary using the given dictionary key. If custom document isn't found, nothing happens.
	GBDocumentData *document = [self.store customDocumentWithKey:key];
	if (!document) return;
	[dict setObject:document forKey:dictKey];
}

- (void)addFooterVarsToDictionary:(NSMutableDictionary *)dict {
    NSString* projectCompanyForFooter = self.settings.projectCompany;
    if ([projectCompanyForFooter hasSuffix:@"."])
    {
        projectCompanyForFooter = [projectCompanyForFooter substringToIndex:projectCompanyForFooter.length - 1];
    }
	[dict setObject:projectCompanyForFooter forKey:@"copyrightHolder"];
	[dict setObject:[self.settings stringByReplacingOccurencesOfPlaceholdersInString:kGBTemplatePlaceholderYear] forKey:@"copyrightDate"];
	[dict setObject:[self.settings stringByReplacingOccurencesOfPlaceholdersInString:kGBTemplatePlaceholderUpdateDate] forKey:@"lastUpdatedDate"];
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

- (NSString *)pageTitleForConstant:(GBTypedefEnumData *)object {
	NSString *template = [self.settings.stringTemplates valueForKeyPath:@"objectPage.constantTitle"];
	return [NSString stringWithFormat:template, object.nameOfEnum];
}

- (NSString *)pageTitleForBlock:(GBTypedefBlockData *)object {
    NSString *template = [self.settings.stringTemplates valueForKeyPath:@"objectPage.blockTitle"];
    return [NSString stringWithFormat:template, object.nameOfBlock];
}


- (NSString *)pageTitleForDocument:(GBDocumentData *)object {
	NSString *template = [self.settings.stringTemplates valueForKeyPath:@"documentPage.titleTemplate"];
	
	//Remove the -template if any
	NSString *lastComp=[[object.nameOfDocument lastPathComponent] stringByDeletingPathExtension];
	NSString *suffix=@"-template";
	if([lastComp hasSuffix:suffix])
		lastComp=[lastComp substringToIndex:[lastComp length] - [suffix length]];
	
	return [NSString stringWithFormat:template, lastComp];
}

- (NSDictionary *)specificationsForClass:(GBClassData *)object {
	NSMutableArray *result = [NSMutableArray array];
	[self registerObjectInheritsFromSpecificationForClass:object toArray:result];
	[self registerObjectConformsToSpecificationForProvider:object toArray:result];
	[self registerObjectDeclaredInSpecificationForProvider:object toArray:result];
	[self registerObjectCompanionGuidesSpecificationForObject:object toArray:result];
	return [self arrayDescriptorForArray:result];
}

- (NSDictionary *)specificationsForCategory:(GBCategoryData *)object {
	NSMutableArray *result = [NSMutableArray array];
	[self registerObjectConformsToSpecificationForProvider:object toArray:result];
	[self registerObjectDeclaredInSpecificationForProvider:object toArray:result];
	[self registerObjectCompanionGuidesSpecificationForObject:object toArray:result];
	return [self arrayDescriptorForArray:result];
}

- (NSDictionary *)specificationsForProtocol:(GBProtocolData *)object {
	NSMutableArray *result = [NSMutableArray array];
	[self registerObjectConformsToSpecificationForProvider:object toArray:result];
	[self registerObjectDeclaredInSpecificationForProvider:object toArray:result];
	[self registerObjectCompanionGuidesSpecificationForObject:object toArray:result];
	return [self arrayDescriptorForArray:result];
}

- (NSDictionary *)specificationsForConstant:(GBProtocolData *)object {
	NSMutableArray *result = [NSMutableArray array];
	[self registerObjectDeclaredInSpecificationForProvider:object toArray:result];
	[self registerObjectCompanionGuidesSpecificationForObject:object toArray:result];
    [self registerObjectAvailabilitySpecificationForProvider:object toArray:result];
	[self registerObjectReferenceSpecificationForProvider:object toArray:result];
	return [self arrayDescriptorForArray:result];
}

- (NSDictionary *)specificationsForBlock:(GBProtocolData *)object {
    NSMutableArray *result = [NSMutableArray array];
    [self registerObjectDeclaredInSpecificationForProvider:object toArray:result];
    [self registerObjectCompanionGuidesSpecificationForObject:object toArray:result];
    [self registerObjectAvailabilitySpecificationForProvider:object toArray:result];
    [self registerObjectReferenceSpecificationForProvider:object toArray:result];
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

- (void)registerObjectAvailabilitySpecificationForProvider:(GBModelBase *)provider toArray:(NSMutableArray *)array {
	
    if([provider.comment.availability.components count] == 0) return;
    
    NSMutableArray *specifications = [NSMutableArray arrayWithCapacity:[provider.comment.availability.components count]];
	NSArray *infos = provider.comment.availability.components;
    [infos enumerateObjectsUsingBlock:^(GBCommentComponent *info, NSUInteger idx, BOOL *stop) {
		NSString *name = info.markdownValue;
		NSDictionary *data = [self objectSpecificationValueWithData:name href:nil];
		[specifications addObject:data];
	}];
	NSArray *values = [self delimitObjectSpecificationValues:specifications withDelimiter:@"<br />"];
	NSString *title = [self.settings.stringTemplates valueForKeyPath:@"objectSpecifications.availability"];
	NSDictionary *data = [self objectSpecificationWithValues:values title:title];
	[array addObject:data];
}

- (void)registerObjectReferenceSpecificationForProvider:(GBModelBase *)provider toArray:(NSMutableArray *)array {
	// Prepares declared in specification with all source files the given object is declared in and adds it to the end of the given array. If the object doesn't contain any source information, nothing happens.
	if ([provider.comment.relatedItems.components count] == 0) return;
    
	NSMutableArray *specifications = [NSMutableArray arrayWithCapacity:[provider.comment.relatedItems.components count]];
	NSArray *infos = provider.comment.relatedItems.components;
	[infos enumerateObjectsUsingBlock:^(GBCommentComponent *info, NSUInteger idx, BOOL *stop) {
        NSString *name = [info stringValue];
        NSString *url = [self hrefForObject:info.relatedItem fromObject:nil];
		NSDictionary *data = [self objectSpecificationValueWithData:name href:url];
		[specifications addObject:data];
	}];
	NSArray *values = [self delimitObjectSpecificationValues:specifications withDelimiter:@"<br />"];
    NSString *title = [self.settings.stringTemplates valueForKeyPath:@"objectSpecifications.references"];
	NSDictionary *data = [self objectSpecificationWithValues:values title:title];
	[array addObject:data];
}

- (void)registerObjectCompanionGuidesSpecificationForObject:(GBModelBase *)object toArray:(NSMutableArray *)array {
	// Prepares companion guides specification with links to all static documents listed in related items of the given object. If the object doesn't contain any related static document, nothing happens.
	if (!object.comment || !object.comment.hasRelatedItems) return;
	NSMutableArray *relatedDocuments = [NSMutableArray array];
	[object.comment.relatedItems.components enumerateObjectsUsingBlock:^(GBCommentComponent *item, NSUInteger idx, BOOL *stop) {
		if ([item.relatedItem isStaticDocument]) {
			NSArray *components = [item.markdownValue captureComponentsMatchedByRegex:self.settings.commentComponents.markdownInlineLinkRegex];
			if ([components count] > 0) {
				NSString *name = [components objectAtIndex:1];
				NSString *href = [components objectAtIndex:2];
				NSDictionary *data = [self objectSpecificationValueWithData:name href:href];
				[relatedDocuments addObject:data];
			}
		}
	}];
	if ([relatedDocuments count] == 0) return;
	NSArray *values = [self delimitObjectSpecificationValues:relatedDocuments withDelimiter:@"<br />"];
	NSString *title = [self.settings.stringTemplates valueForKeyPath:@"objectSpecifications.companionGuide"];
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
	NSString *template = [self.settings.stringTemplates.indexPage objectForKey:@"titleTemplate"];
	return [NSString stringWithFormat:template, self.settings.projectName];
}

- (NSString *)pageTitleForHierarchy {
	NSString *template = [self.settings.stringTemplates.hierarchyPage objectForKey:@"titleTemplate"];
	return [NSString stringWithFormat:template, self.settings.projectName];
}

- (NSArray*)documentsForIndex{
    NSArray *documents = [self.store documentsSortedByName];
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:[documents count]];
	for (GBDocumentData *document in documents) {
		NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:2];
		[data setObject:[self hrefForObject:document fromObject:nil] forKey:@"href"];
		[data setObject:document.prettyNameOfDocument forKey:@"title"];
		[result addObject:data];
	}
	return result;
}

- (NSArray *)classesForIndex {
	NSArray *classes = [self.store classesSortedByName];
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:[classes count]];
	for (GBClassData *class in classes) {
        if (!class.includeInOutput) continue;
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
        if (!category.includeInOutput) continue;
		NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:2];
		[data setObject:[self hrefForObject:category fromObject:nil] forKey:@"href"];
		[data setObject:category.idOfCategory forKey:@"title"];
		[result addObject:data];
	}
	return result;
}

- (NSArray *)constantsForIndex {
	NSArray *constants = [self.store constantsSortedByName];
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:[constants count]];
	for (GBTypedefEnumData *constant in constants) {
        if (!constant.includeInOutput) continue;
		NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:2];
		[data setObject:[self hrefForObject:constant fromObject:nil] forKey:@"href"];
		[data setObject:constant.nameOfEnum forKey:@"title"];
		[result addObject:data];
	}
	return result;
}

- (NSArray *)blocksForIndex {
    NSArray *blocks = [self.store blocksSortedByName];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[blocks count]];
    for (GBTypedefBlockData *block in blocks) {
        if (!block.includeInOutput) continue;
        NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:2];
        [data setObject:[self hrefForObject:block fromObject:nil] forKey:@"href"];
        [data setObject:block.nameOfBlock forKey:@"title"];
        [result addObject:data];
    }
    return result;
}

- (NSArray *)protocolsForIndex {
	NSArray *protocols = [self.store protocolsSortedByName];
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:[protocols count]];
	for (GBProtocolData *protocol in protocols) {
        if (!protocol.includeInOutput) continue;
		NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:2];
		[data setObject:[self hrefForObject:protocol fromObject:nil] forKey:@"href"];
		[data setObject:protocol.nameOfProtocol forKey:@"title"];
		[result addObject:data];
	}
	return result;
}

- (NSArray *)classesForHierarchy {
	// This returns the array of all root classes, each class containing further arrays of subclasses and so on. Ussually root classes array only contains single NSObject class, but can also include all root classes (not derived from NSObject). The algorithm for creating hierarhy is not state of the art, but it's quite simple and effective: for each class we iterate over it's whole hierarchy until we arrive at it's root class, creating an flat list of hierarchy for this class. Then we use the flat list to add all unknown class names to the hierarchy dictionary, together with all subclasses. When we process all classes like this, we have a dictionary with proper inheritance.
	NSMutableDictionary *hierarchy = [NSMutableDictionary dictionaryWithCapacity:[self.store.classes count]];
	for (GBClassData *class in [self.store.classes allObjects]) {
        if (!class.includeInOutput) continue;
		// Build the flat list of class hierarchy up to the root class. The flat lists array starts with root and ends with current class. Note how we treat unknown classes as root classes - if a class doesn't have a pointer to superclass, but does have it's name, we add the name to the flat list. Although this does end with usable hierarhcy, it does leave things open for improvements (i.e. deriving from NSView will not create the hierarchy all the way down to NSObject, but will instead use NSView as a root view, besides NSObject).
		GBClassData *c = class;
		NSMutableArray *flatlist = [NSMutableArray array];
		while (c) {
			[flatlist insertObject:c.nameOfClass atIndex:0];
			if (!c.superclass && c.nameOfSuperclass) [flatlist insertObject:c.nameOfSuperclass atIndex:0];
			c = c.superclass;
		}
		
		// Now traverse the flat list and add all unknown classes to the dictionary. Then add all subclasses to next level and update the data we'll be matching in the next iteration (i.e. subclasses). This way we always start with the root dictionary and progress the depth on each iteration.
		NSMutableDictionary *currentLevel = hierarchy;
		for (NSString *className in flatlist) {
			NSMutableDictionary *classData = [currentLevel objectForKey:className];
			if (!classData) {
				classData = [NSMutableDictionary dictionary];
				[classData setObject:className forKey:@"name"];
				[classData setObject:[NSMutableDictionary dictionary] forKey:@"subclasses"];
				[currentLevel setObject:classData forKey:className];
			}
			currentLevel = [classData objectForKey:@"subclasses"];
		}
	}
	
	// Finally convert hierarchy dictionary to arrays of arrays. Although the dictionary contains all objects, it stores them under keys matching object names. This made it simple to add new objects, but gives template engine no known key to work with. So basically we're converting each layer of hierarchy data into an array of dictionaries.
	return [self arrayFromHierarchyLevel:hierarchy];
}

- (NSArray *)arrayFromHierarchyLevel:(NSDictionary *)level {
	// A helper method that recursively descends the given hierarchy level dictionary and converts it to array suitable for template engine processing.
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:[level count]];
	[level enumerateKeysAndObjectsUsingBlock:^(NSString *name, NSDictionary *data, BOOL *stop) {
		// Get all sublasses by recursively descending down the hierarchy.
		NSArray *subclasses = [self arrayFromHierarchyLevel:[data objectForKey:@"subclasses"]];
		
		// Get current class from the store and href to it.
		GBClassData *class = [self.store classWithName:name];
		NSString *href = [self hrefForObject:class fromObject:nil];
		
		// Prepare class data.
		NSMutableDictionary *classData = [NSMutableDictionary dictionary];
		[classData setObject:name forKey:@"name"];
		[classData setObject:subclasses forKey:@"classes"];
		[classData setObject:[NSNumber numberWithBool:([subclasses count] > 0)] forKey:@"hasClasses"];
		if (href) [classData setObject:href forKey:@"href"];
		[result addObject:classData];
	}];
	
	// Sort the array by class names.
	NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
	return [result sortedArrayUsingDescriptors:descriptors];
}

- (void)registerObjectsUsageForIndexInDictionary:(NSMutableDictionary *)dict {
	BOOL documents = [self.store.documents count] > 0;
	BOOL classes = [self.store.classes count] > 0;
	BOOL categories = [self.store.categories count] > 0;
	BOOL protocols = [self.store.protocols count] > 0;
    BOOL constants = [self.store.constants count] > 0;
    BOOL blocks = [self.store.blocks count] > 0;
    [dict setObject:[NSNumber numberWithBool:documents] forKey:@"hasDocs"];
    [dict setObject:[NSNumber numberWithBool:classes] forKey:@"hasClasses"];
	[dict setObject:[NSNumber numberWithBool:categories] forKey:@"hasCategories"];
	[dict setObject:[NSNumber numberWithBool:protocols] forKey:@"hasProtocols"];
	[dict setObject:[NSNumber numberWithBool:constants] forKey:@"hasConstants"];
    [dict setObject:[NSNumber numberWithBool:blocks] forKey:@"hasBlocks"];
	[dict setObject:[NSNumber numberWithBool:protocols || categories || constants || blocks] forKey:@"hasProtocolsOrCategories"];
}

@end
