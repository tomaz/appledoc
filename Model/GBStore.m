//
//  GBStore.m
//  appledoc
//
//  Created by Tomaz Kragelj on 25.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBDataObjects.h"
#import "GBStore.h"
#import "SynthesizeSingleton.h"

@implementation GBStore

SYNTHESIZE_SINGLETON_FOR_CLASS(GBStore, sharedStore);

#pragma mark Initialization & disposal

- (id)init {
	self = [super init];
	if (self) {
		_classes = [[NSMutableSet alloc] init];
		_classesByName = [[NSMutableDictionary alloc] init];
		_categories = [[NSMutableSet alloc] init];
		_categoriesByName = [[NSMutableDictionary alloc] init];
		_protocols = [[NSMutableSet alloc] init];
		_protocolsByName = [[NSMutableDictionary alloc] init];
		_documents = [[NSMutableSet alloc] init];
		_documentsByName = [[NSMutableDictionary alloc] init];
        _typedefEnums = [[NSMutableSet alloc] init];
        _typedefEnumsByName = [[NSMutableDictionary alloc] init];
        _typedefBlocks = [[NSMutableSet alloc] init];
        _typedefBlocksByName = [[NSMutableDictionary alloc] init];
		_customDocuments = [[NSMutableSet alloc] init];
		_customDocumentsByKey = [[NSMutableDictionary alloc] init];
	}
	return self;
}

#pragma mark Overriden methods

- (NSString *)debugDescription {
	return [NSString stringWithFormat:@"%@{ %lu classes, %lu categories, %lu protocols }", [self className], [self.classes count], [self.categories count], [self.protocols count]];
}

#pragma mark Helper methods

- (NSArray *)documentsSortedByName{
	NSArray *descriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"prettyNameOfDocument" ascending:YES]];
	return [[self.documents allObjects] sortedArrayUsingDescriptors:descriptors];
}

- (NSArray *)classesSortedByName {
	NSArray *descriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"nameOfClass" ascending:YES]];
	return [[self.classes allObjects] sortedArrayUsingDescriptors:descriptors];
}


- (NSArray *)constantsSortedByName {
	NSArray *descriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"nameOfEnum" ascending:YES]];
	return [[self.constants allObjects] sortedArrayUsingDescriptors:descriptors];
}

- (NSArray *)blocksSortedByName {
    NSArray *descriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"nameOfBlock" ascending:YES]];
    return [[self.blocks allObjects] sortedArrayUsingDescriptors:descriptors];
}


- (NSArray *)categoriesSortedByName {
	NSSortDescriptor *classNameDescription = [NSSortDescriptor sortDescriptorWithKey:@"nameOfClass" ascending:YES];
	NSSortDescriptor *categoryNameDescription = [NSSortDescriptor sortDescriptorWithKey:@"categoryName" ascending:YES];
	NSArray *descriptors = @[classNameDescription, categoryNameDescription];
	return [[self.categories allObjects] sortedArrayUsingDescriptors:descriptors];
}

- (NSArray *)protocolsSortedByName {
	NSArray *descriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"protocolName" ascending:YES]];
	return [[self.protocols allObjects] sortedArrayUsingDescriptors:descriptors];
}

#pragma mark Registration handling

- (void)registerClass:(GBClassData *)class {
	NSParameterAssert(class != nil);
	GBLogDebug(@"Registering class %@...", class);
	if ([_classes containsObject:class]) return;
	GBClassData *existingClass = _classesByName[class.nameOfClass];
	if (existingClass) {
		[existingClass mergeDataFromObject:class];
		return;
	}
	[_classes addObject:class];
	_classesByName[class.nameOfClass] = class;
}

- (void)registerCategory:(GBCategoryData *)category {
	NSParameterAssert(category != nil);
	GBLogDebug(@"Registering category %@...", category);
	if ([_categories containsObject:category]) return;
	NSString *categoryID = [NSString stringWithFormat:@"%@(%@)", category.nameOfClass, category.nameOfCategory ? category.nameOfCategory : @""];
	GBCategoryData *existingCategory = _categoriesByName[categoryID];
	if (existingCategory) {
		[existingCategory mergeDataFromObject:category];
		return;
	}
	[_categories addObject:category];
	_categoriesByName[categoryID] = category;
}

- (void)registerProtocol:(GBProtocolData *)protocol {
	NSParameterAssert(protocol != nil);
	GBLogDebug(@"Registering class %@...", protocol);
	if ([_protocols containsObject:protocol]) return;
	GBProtocolData *existingProtocol = _protocolsByName[protocol.nameOfProtocol];
	if (existingProtocol) {
		[existingProtocol mergeDataFromObject:protocol];
		return;
	}
	[_protocols addObject:protocol];
	_protocolsByName[protocol.nameOfProtocol] = protocol;
}

-(void)registerTypedefEnum:(GBTypedefEnumData *)typedefEnum
{
    NSParameterAssert(typedefEnum != nil);
	GBLogDebug(@"Registering typedef enum %@...", typedefEnum);
	if ([_typedefEnums containsObject:typedefEnum]) return;
	GBProtocolData *existingTypedef = _typedefEnumsByName[typedefEnum.nameOfEnum];
	if (existingTypedef) {
        GBLogWarn(@"Ignoring typedef enum %@, already defined.", typedefEnum);
        return;
    }

	[_typedefEnums addObject:typedefEnum];
	_typedefEnumsByName[typedefEnum.nameOfEnum] = typedefEnum;
}

-(void)registerTypedefBlock:(GBTypedefBlockData *)typedefBlock
{
    NSParameterAssert(typedefBlock != nil);
    GBLogDebug(@"Registering typedef block %@...", typedefBlock);
    if ([_typedefBlocks containsObject:typedefBlock]) return;
    GBProtocolData *existingTypedef = _typedefBlocksByName[typedefBlock.nameOfBlock];
    if (existingTypedef) {
        GBLogWarn(@"Ignoring typedef block %@, already defined.", typedefBlock);
        return;
    }
    
    [_typedefBlocks addObject:typedefBlock];
    _typedefBlocksByName[typedefBlock.nameOfBlock] = typedefBlock;
}


- (void)registerDocument:(GBDocumentData *)document {
	NSParameterAssert(document != nil);
	GBLogDebug(@"Registering document %@...", document);
	if ([_documents containsObject:document]) return;
	NSString *name = [document.nameOfDocument stringByDeletingPathExtension];
	GBDocumentData *existingDocument = _documentsByName[name];
    if (existingDocument) {
        GBLogWarn(@"Ignoring document %@, already defined.", document);
        return;
    }

	[_documents addObject:document];
	_documentsByName[name] = document;
	_documentsByName[[name stringByReplacingOccurrencesOfString:@"-template" withString:@""]] = document;
}

- (void)registerCustomDocument:(GBDocumentData *)document withKey:(id)key {
	NSParameterAssert(document != nil);
	GBLogDebug(@"Registering custom document %@...", document);
	[_customDocuments addObject:document];
	_customDocumentsByKey[key] = document;
}

- (void)unregisterTopLevelObject:(id)object {
	if ([_classes containsObject:object]) {
		[_classes removeObject:object];
		[_classesByName removeObjectForKey:[object nameOfClass]];
		return;
	}
	if ([_categories containsObject:object]) {
		[_categories removeObject:object];
		[_categoriesByName removeObjectForKey:[object idOfCategory]];
		return;
	}
	if ([_protocols containsObject:object]) {
		[_protocols removeObject:object];
		[_protocolsByName removeObjectForKey:[object nameOfProtocol]];
		return;
	}
}

#pragma mark Data providing

- (GBClassData *)classWithName:(NSString *)name {
	return _classesByName[name];
}

- (GBCategoryData *)categoryWithName:(NSString *)name {
	return _categoriesByName[name];
}

- (GBProtocolData *)protocolWithName:(NSString *)name {
	return _protocolsByName[name];
}

- (GBDocumentData *)documentWithName:(NSString *)path {
	return _documentsByName[path];
}

- (GBTypedefEnumData *)typedefEnumWithName:(NSString *)path {
	return _typedefEnumsByName[path];
}

- (GBTypedefBlockData *)typedefBlockWithName:(NSString *)path {
    return _typedefBlocksByName[path];
}

- (GBDocumentData *)customDocumentWithKey:(id)key {
	return _customDocumentsByKey[key];
}

@synthesize classes = _classes;
@synthesize categories = _categories;
@synthesize protocols = _protocols;
@synthesize constants = _typedefEnums;
@synthesize blocks = _typedefBlocks;
@synthesize documents = _documents;
@synthesize customDocuments = _customDocuments;

@end
