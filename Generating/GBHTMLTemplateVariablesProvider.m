//
//  GBHTMLTemplateVariablesProvider.m
//  appledoc
//
//  Created by Tomaz Kragelj on 1.10.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <RegexKitLite/RegexKitLite.h>
#import <GRMustache/GRMustache.h>
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
- (NSString *)docsSectionTitleForIndex;
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
	page[@"title"] = [self pageTitleForClass:object];
	page[@"specifications"] = [self specificationsForClass:object];
	[self addFooterVarsToDictionary:page];
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	result[@"page"] = page;
	result[@"object"] = object;
	result[@"projectCompany"] = self.settings.projectCompany;
	result[@"projectName"] = self.settings.projectName;
	result[@"strings"] = self.settings.stringTemplates;
	return result;
}

- (NSDictionary *)variablesForCategory:(GBCategoryData *)object withStore:(id)aStore {
	self.store = aStore;
	NSMutableDictionary *page = [NSMutableDictionary dictionary];
	page[@"title"] = [self pageTitleForCategory:object];
	page[@"specifications"] = [self specificationsForCategory:object];
	[self addFooterVarsToDictionary:page];
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	result[@"page"] = page;
	result[@"object"] = object;
	result[@"projectCompany"] = self.settings.projectCompany;
	result[@"projectName"] = self.settings.projectName;
	
	result[@"strings"] = self.settings.stringTemplates;
	return result;
}

- (NSDictionary *)variablesForProtocol:(GBProtocolData *)object withStore:(id)aStore {
	self.store = aStore;
	NSMutableDictionary *page = [NSMutableDictionary dictionary];
	page[@"title"] = [self pageTitleForProtocol:object];
	page[@"specifications"] = [self specificationsForProtocol:object];
	[self addFooterVarsToDictionary:page];
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	result[@"page"] = page;
	result[@"object"] = object;
	result[@"projectCompany"] = self.settings.projectCompany;
	result[@"projectName"] = self.settings.projectName;
	result[@"strings"] = self.settings.stringTemplates;
	return result;
}

- (NSDictionary *)variablesForConstant:(GBTypedefEnumData *)typedefEnum withStore:(id)aStore {
	self.store = aStore;
	NSMutableDictionary *page = [NSMutableDictionary dictionary];
	page[@"title"] = [self pageTitleForConstant:typedefEnum];
	page[@"specifications"] = [self specificationsForConstant:typedefEnum];
	[self addFooterVarsToDictionary:page];
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	result[@"page"] = page;
	result[@"typedefEnum"] = typedefEnum;
	result[@"projectCompany"] = self.settings.projectCompany;
	result[@"projectName"] = self.settings.projectName;
	result[@"strings"] = self.settings.stringTemplates;
	return result;
}

- (NSDictionary *)variablesForBlocks:(GBTypedefBlockData *)typedefBlock withStore:(id)aStore {
    self.store = aStore;
    NSMutableDictionary *page = [NSMutableDictionary dictionary];
    page[@"title"] = [self pageTitleForBlock:typedefBlock];
    page[@"specifications"] = [self specificationsForBlock:typedefBlock];
    [self addFooterVarsToDictionary:page];
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    result[@"page"] = page;
    result[@"typedefBlock"] = typedefBlock;
    result[@"projectCompany"] = self.settings.projectCompany;
    result[@"projectName"] = self.settings.projectName;
    result[@"strings"] = self.settings.stringTemplates;
    return result;
}


- (NSDictionary *)variablesForDocument:(GBDocumentData *)object withStore:(id)aStore {
	self.store = aStore;
	NSString *path = [self.settings htmlRelativePathToIndexFromObject:object];
	NSMutableDictionary *page = [NSMutableDictionary dictionary];
	page[@"title"] = [self pageTitleForDocument:object];
	page[@"cssPath"] = [path stringByAppendingPathComponent:@"css/style.css"];
	page[@"cssPrintPath"] = [path stringByAppendingPathComponent:@"css/stylePrint.css"];
	page[@"jsPath"] = [path stringByAppendingPathComponent:@"js/script.js"];
  page[@"documentationIndexPath"] = [path stringByAppendingPathComponent:@"index.html"];
	[self addFooterVarsToDictionary:page];
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	result[@"page"] = page;
	result[@"object"] = object;
	result[@"projectCompany"] = self.settings.projectCompany;
	result[@"projectName"] = self.settings.projectName;
	result[@"strings"] = self.settings.stringTemplates;
	[self addFooterVarsToDictionary:result];
	return result;
}

#pragma mark Index variables handling

- (NSDictionary *)variablesForIndexWithStore:(id)aStore {
	self.store = aStore;
	NSMutableDictionary *page = [NSMutableDictionary dictionary];
	page[@"title"] = [self pageTitleForIndex];
    page[@"docsTitle"] = [self docsSectionTitleForIndex];
	[self addFooterVarsToDictionary:page];
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	result[@"page"] = page;
	result[@"docs"] = [self documentsForIndex];
	result[@"classes"] = [self classesForIndex];
	result[@"protocols"] = [self protocolsForIndex];
	result[@"categories"] = [self categoriesForIndex];
    result[@"constants"] = [self constantsForIndex];
    result[@"blocks"] = [self blocksForIndex];
	result[@"strings"] = self.settings.stringTemplates;
	result[@"projectCompany"] = self.settings.projectCompany;
	result[@"projectName"] = self.settings.projectName;
	
	[self addCustomDocumentWithKey:kGBCustomDocumentIndexDescKey toDictionary:result key:@"indexDescription"];
	[self registerObjectsUsageForIndexInDictionary:result];
	return result;
}

- (NSDictionary *)variablesForHierarchyWithStore:(id)aStore {
	self.store = aStore;
	NSMutableDictionary *page = [NSMutableDictionary dictionary];
	page[@"title"] = [self pageTitleForHierarchy];
	[self addFooterVarsToDictionary:page];
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	result[@"page"] = page;
	result[@"classes"] = [self classesForHierarchy];
	result[@"protocols"] = [self protocolsForIndex];
	result[@"categories"] = [self categoriesForIndex];
	result[@"constants"] = [self constantsForIndex];
    result[@"blocks"] = [self blocksForIndex];
    result[@"strings"] = self.settings.stringTemplates;
	result[@"projectCompany"] = self.settings.projectCompany;
	result[@"projectName"] = self.settings.projectName;
	
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
		result[@"used"] = @YES;
		result[@"values"] = array;
		return result;
	}
	result[@"used"] = @NO;
	return result;
}

#pragma mark Common values

- (void)addCustomDocumentWithKey:(id)key toDictionary:(NSMutableDictionary *)dict key:(id)dictKey {
	// Adds custom document with the given key to the given dictionary using the given dictionary key. If custom document isn't found, nothing happens.
	GBDocumentData *document = [self.store customDocumentWithKey:key];
	if (!document) return;
	dict[dictKey] = document;
}

- (void)addFooterVarsToDictionary:(NSMutableDictionary *)dict {
    NSString* projectCompanyForFooter = self.settings.projectCompany;
    if ([projectCompanyForFooter hasSuffix:@"."])
    {
        projectCompanyForFooter = [projectCompanyForFooter substringToIndex:projectCompanyForFooter.length - 1];
    }
	dict[@"copyrightHolder"] = projectCompanyForFooter;
	dict[@"copyrightDate"] = [self.settings stringByReplacingOccurencesOfPlaceholdersInString:kGBTemplatePlaceholderYear];
	dict[@"lastUpdatedDate"] = [self.settings stringByReplacingOccurencesOfPlaceholdersInString:kGBTemplatePlaceholderUpdateDate];
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
				NSString *name = components[1];
				NSString *href = components[2];
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
	result[@"title"] = title;
	result[@"values"] = values;
	return result;
}

- (NSDictionary *)objectSpecificationValueWithData:(id)data href:(NSString *)href {
	// Prepares single specification value.
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	if (href) result[@"href"] = href;
	result[@"string"] = data;
	result[@"delimiter"] = @"";
	return result;
}

- (NSArray *)delimitObjectSpecificationValues:(NSArray *)values withDelimiter:(NSString *)delimiter {
	// The array should contain mutable dictionaries with keys "data" and "href". We simplt add the delimiter to all but last value and use it to prepare the resulting specification dictionary containing all values.
	[values enumerateObjectsUsingBlock:^(NSMutableDictionary *data, NSUInteger idx, BOOL *stop) {
		if (idx < [values count] - 1) data[@"delimiter"] = delimiter;
	}];
	return values;
}

@end

#pragma mark -

@implementation GBHTMLTemplateVariablesProvider (IndexVariables)

- (NSString *)pageTitleForIndex {
	NSString *template = self.settings.stringTemplates.indexPage[@"titleTemplate"];
	return [NSString stringWithFormat:template, self.settings.projectName];
}

- (NSString *)pageTitleForHierarchy {
	NSString *template = self.settings.stringTemplates.hierarchyPage[@"titleTemplate"];
	return [NSString stringWithFormat:template, self.settings.projectName];
}

- (NSString *)docsSectionTitleForIndex {
    if ([self.settings.docsSectionTitle length] > 0)
    {
        return self.settings.docsSectionTitle;
    }
    
    return self.settings.stringTemplates.indexPage[@"docsTitle"];
}

- (NSArray*)documentsForIndex{
    NSArray *documents = [self.store documentsSortedByName];
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:[documents count]];
	for (GBDocumentData *document in documents) {
		NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:2];
		data[@"href"] = [self hrefForObject:document fromObject:nil];
		data[@"title"] = document.prettyNameOfDocument;
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
		data[@"href"] = [self hrefForObject:class fromObject:nil];
		data[@"title"] = class.nameOfClass;
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
		data[@"href"] = [self hrefForObject:category fromObject:nil];
		data[@"title"] = category.idOfCategory;
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
		data[@"href"] = [self hrefForObject:constant fromObject:nil];
		data[@"title"] = constant.nameOfEnum;
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
        data[@"href"] = [self hrefForObject:block fromObject:nil];
        data[@"title"] = block.nameOfBlock;
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
		data[@"href"] = [self hrefForObject:protocol fromObject:nil];
		data[@"title"] = protocol.nameOfProtocol;
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
			NSMutableDictionary *classData = currentLevel[className];
			if (!classData) {
				classData = [NSMutableDictionary dictionary];
				classData[@"name"] = className;
				classData[@"subclasses"] = [NSMutableDictionary dictionary];
				currentLevel[className] = classData;
			}
			currentLevel = classData[@"subclasses"];
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
		NSArray *subclasses = [self arrayFromHierarchyLevel:data[@"subclasses"]];
		
		// Get current class from the store and href to it.
		GBClassData *class = [self.store classWithName:name];
		NSString *href = [self hrefForObject:class fromObject:nil];
		
		// Prepare class data.
		NSMutableDictionary *classData = [NSMutableDictionary dictionary];
		classData[@"name"] = name;
		classData[@"classes"] = subclasses;
		classData[@"hasClasses"] = @([subclasses count] > 0);
		if (href) classData[@"href"] = href;
		[result addObject:classData];
	}];
	
	// Sort the array by class names.
	NSArray *descriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
	return [result sortedArrayUsingDescriptors:descriptors];
}

- (void)registerObjectsUsageForIndexInDictionary:(NSMutableDictionary *)dict {
	BOOL documents = [self.store.documents count] > 0;
	BOOL classes = [self.store.classes count] > 0;
	BOOL categories = [self.store.categories count] > 0;
	BOOL protocols = [self.store.protocols count] > 0;
    BOOL constants = [self.store.constants count] > 0;
    BOOL blocks = [self.store.blocks count] > 0;
    dict[@"hasDocs"] = @(documents);
    dict[@"hasClasses"] = @(classes);
	dict[@"hasCategories"] = @(categories);
	dict[@"hasProtocols"] = @(protocols);
	dict[@"hasConstants"] = @(constants);
    dict[@"hasBlocks"] = @(blocks);
	dict[@"hasProtocolsOrCategories"] = @(protocols || categories || constants || blocks);
}

@end
