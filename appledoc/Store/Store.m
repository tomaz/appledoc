//
//  Store.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/19/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "ObjectsCacher.h"
#import "Store.h"

@interface Store ()
@property (nonatomic, readonly) id previousRegistrationObject;
@property (nonatomic, strong) id lastPoppedRegistrationObject;
@property (nonatomic, strong) PKToken *currentSourceInfo;
@property (nonatomic, copy) NSString *commentTextForNextObject;
@property (nonatomic, strong) NSMutableArray *registrationStack;
@end

#pragma mark - 

@implementation Store

- (BOOL)expectCurrentRegistrationObjectRespondTo:(SEL)selector {
	if (self.registrationStack.count == 0) {
		LogWarn(@"Expecting at least one object responding to %@ on registration stack!", NSStringFromSelector(selector));
		return NO;
	}
	if (![self.currentRegistrationObject respondsToSelector:selector]) {
		LogWarn(@"Current object %@ on registration stack doesn't respond to %@!", self.currentRegistrationObject, NSStringFromSelector(selector));
		return NO;
	}
	return YES;
}

- (BOOL)doesCurrentRegistrationObjectRespondTo:(SEL)selector {
	if (self.registrationStack.count == 0) return NO;
	if (![self.currentRegistrationObject respondsToSelector:selector]) return NO;
	return YES;
}

- (BOOL)doesPreviousRegistrationObjectRespondTo:(SEL)selector {
	id object = self.previousRegistrationObject;
	if (!object) return NO;
	if (![object respondsToSelector:selector]) return NO;
	return YES;
}

- (void)pushRegistrationObject:(id)object {
	LogDebug(@"Pushing %@ to registration stack...", object);
	if (self.commentTextForNextObject) {
		if (![object respondsToSelector:@selector(setComment:)]) {
			LogWarn(@"%@ doesn't respond to setComment:, can't register comment!", object);
		} else {
			LogDebug(@"Registering comment %@...", [self.commentTextForNextObject gb_description]);
			[self createCommentFromText:self.commentTextForNextObject registerTo:object];
		}
		self.commentTextForNextObject = nil;
	}
	[self.registrationStack addObject:object];
}

- (id)popRegistrationObject {
	id result = self.currentRegistrationObject;
	LogDebug(@"Popping %@ from registration stack...", result);
	self.lastPoppedRegistrationObject = result;
	[self.registrationStack removeLastObject];
	return result;
}

- (id)currentRegistrationObject {
	return [self.registrationStack lastObject];
}

- (id)previousRegistrationObject {
	if (self.registrationStack.count < 2) return nil;
	NSUInteger index = self.registrationStack.count - 2;
	return (self.registrationStack)[index];
}

- (NSMutableArray *)registrationStack {
	if (_registrationStack) return _registrationStack;
	LogDebug(@"Initializing registration stack due to first access...");
	_registrationStack = [[NSMutableArray alloc] init];
	return _registrationStack;
}

#pragma mark - Common functionality

- (void)createCommentFromText:(NSString *)text registerTo:(id)object {
	LogVerbose(@"Creating comment from %@ for %@...", [text gb_description], object);
	CommentInfo *info = [[CommentInfo alloc] init];
	info.sourceToken = self.currentSourceInfo;
	info.sourceString = text;
	[object setComment:info];
}

#pragma mark - Customized modifiers

- (void)setCurrentSourceInfo:(PKToken *)value {
	LogDebug(@"Changing current source info to line %lu...", value.location.y);
	_currentSourceInfo = value;
	if ([self doesCurrentRegistrationObjectRespondTo:@selector(setCurrentSourceInfo:)]) {
		LogDebug(@"Passing source info to current registration object...");
		[self.currentRegistrationObject setCurrentSourceInfo:value];
	}
}

#pragma mark - Properties

- (NSMutableArray *)storeClasses {
	if (_storeClasses) return _storeClasses;
	LogDebug(@"Initializing store classes array due to first access...");
	_storeClasses = [[NSMutableArray alloc] init];
	return _storeClasses;
}

- (NSMutableArray *)storeExtensions {
	if (_storeExtensions) return _storeExtensions;
	LogDebug(@"Initializing store extensions array due to first access...");
	_storeExtensions = [[NSMutableArray alloc] init];
	return _storeExtensions;
}

- (NSMutableArray *)storeCategories {
	if (_storeCategories) return _storeCategories;
	LogDebug(@"Initializing store categories array due to first access...");
	_storeCategories = [[NSMutableArray alloc] init];
	return _storeCategories;
}

- (NSMutableArray *)storeProtocols {
	if (_storeProtocols) return _storeProtocols;
	LogDebug(@"Initializing store protocols array due to first access...");
	_storeProtocols = [[NSMutableArray alloc] init];
	return _storeProtocols;
}

- (NSMutableArray *)storeEnumerations {
	if (_storeEnumerations) return _storeEnumerations;
	LogDebug(@"Initializing store enumerations array due to first access...");
	_storeEnumerations = [[NSMutableArray alloc] init];
	return _storeEnumerations;
}

- (NSMutableArray *)storeStructs {
	if (_storeStructs) return _storeStructs;
	LogDebug(@"Initializing store structs array due to first access...");
	_storeStructs = [[NSMutableArray alloc] init];
	return _storeStructs;
}

- (NSMutableArray *)storeConstants {
	if (_storeConstants) return _storeConstants;
	LogDebug(@"Initializing store constants array due to first access...");
	_storeConstants = [[NSMutableArray alloc] init];
	return _storeConstants;
}

#pragma mark - Cache handling

- (NSMutableDictionary *)topLevelObjectsCache {
	// Don't use this until ALL objects are registered; it'll only create cache once, from current data!
	if (_topLevelObjectsCache) return _topLevelObjectsCache;
	NSDictionary *cache = [ObjectsCacher cacheTopLevelObjectsFromStore:self interface:^id(ObjectInfoBase *obj) {
		return obj.uniqueObjectID;
	}];
	_topLevelObjectsCache = [cache mutableCopy];
	return _topLevelObjectsCache;
}

- (NSMutableDictionary *)memberObjectsCache {
	if (_memberObjectsCache) return _memberObjectsCache;
	NSDictionary *cache = [ObjectsCacher cacheMembersFromStore:self classMethod:^id(InterfaceInfoBase *interface, ObjectInfoBase *obj) {
		return [NSString stringWithFormat:@"+[%@ %@]", interface.uniqueObjectID, obj.uniqueObjectID];
	} instanceMethod:^id(InterfaceInfoBase *interface, ObjectInfoBase *obj) {
		return [NSString stringWithFormat:@"-[%@ %@]", interface.uniqueObjectID, obj.uniqueObjectID];
	} property:^id(InterfaceInfoBase *interface, ObjectInfoBase *obj) {
		PropertyInfo *property = (PropertyInfo *)obj;
		return @[
			[NSString stringWithFormat:@"[%@ %@]", interface.uniqueObjectID, property.uniqueObjectID],
			[NSString stringWithFormat:@"-[%@ %@]", interface.uniqueObjectID, property.propertyGetterSelector],
			[NSString stringWithFormat:@"-[%@ %@]", interface.uniqueObjectID, property.propertySetterSelector]
		];
	}];
	_memberObjectsCache = [cache mutableCopy];
	return _memberObjectsCache;
}

@end

#pragma mark - 

#pragma mark - 

@implementation Store (Registrations)

#pragma mark - Classes, categories and protocols handling

- (void)beginClassWithName:(NSString *)name derivedFromClassWithName:(NSString *)derived {
	LogVerbose(@"Starting class %@ derived from %@...", name, derived);
	ClassInfo *info = [[ClassInfo alloc] initWithRegistrar:self];
	info.sourceToken = self.currentSourceInfo;
	info.nameOfClass = name;
	info.classSuperClass.nameOfObject = derived;
	[self.storeClasses addObject:info];
	[self pushRegistrationObject:info];
}

- (void)beginExtensionForClassWithName:(NSString *)name {
	LogVerbose(@"Starting class extenstion for class %@...", name);
	CategoryInfo *info = [[CategoryInfo alloc] initWithRegistrar:self];
	info.sourceToken = self.currentSourceInfo;
	info.nameOfClass = name;
	info.nameOfCategory = nil;
	[self.storeExtensions addObject:info];
	[self pushRegistrationObject:info];
}

- (void)beginCategoryWithName:(NSString *)category forClassWithName:(NSString *)name {
	LogVerbose(@"Starting category %@ for class %@...", category, name);
	CategoryInfo *info = [[CategoryInfo alloc] initWithRegistrar:self];
	info.sourceToken = self.currentSourceInfo;
	info.nameOfClass = name;
	info.nameOfCategory = category;
	[self.storeCategories addObject:info];
	[self pushRegistrationObject:info];
}

- (void)beginProtocolWithName:(NSString *)name {
	LogVerbose(@"Starting protocol %@...", name);
	ProtocolInfo *info = [[ProtocolInfo alloc] initWithRegistrar:self];
	info.sourceToken = self.currentSourceInfo;
	info.nameOfProtocol = name;
	[self.storeProtocols addObject:info];
	[self pushRegistrationObject:info];
}

- (void)appendAdoptedProtocolWithName:(NSString *)name {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogDebug(@"Forwarding adopted protocol registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject appendAdoptedProtocolWithName:name];
}

#pragma mark - Method groups

- (void)appendMethodGroupWithDescription:(NSString *)description {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogDebug(@"Forwarding method group description registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject appendMethodGroupWithDescription:description];
}

#pragma mark - Properties

- (void)beginPropertyDefinition {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogDebug(@"Forwarding property definition registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject beginPropertyDefinition];
}

- (void)beginPropertyAttributes {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogDebug(@"Forwarding property attributes registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject beginPropertyAttributes];
}

- (void)beginPropertyTypes {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogDebug(@"Forwarding property types registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject beginPropertyTypes];
}

- (void)beginPropertyDescriptors {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogDebug(@"Forwarding property descriptors registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject beginPropertyDescriptors];
}

- (void)appendPropertyName:(NSString *)name {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogDebug(@"Forwarding property name registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject appendPropertyName:name];
}

#pragma mark - Methods

- (void)beginMethodDefinitionWithType:(NSString *)type {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogDebug(@"Forwarding method definition registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject beginMethodDefinitionWithType:type];
}

- (void)beginMethodResults {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogDebug(@"Forwarding method results registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject beginMethodResults];
}

- (void)beginMethodArgument {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogDebug(@"Forwarding method arguments registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject beginMethodArgument];
}

- (void)beginMethodArgumentTypes {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogDebug(@"Forwarding method argument types registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject beginMethodArgumentTypes];
}

- (void)beginMethodDescriptors {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogDebug(@"Forwarding method descriptors registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject beginMethodDescriptors];
}

- (void)appendMethodArgumentSelector:(NSString *)name {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogDebug(@"Forwarding method argument selector registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject appendMethodArgumentSelector:name];
}

- (void)appendMethodArgumentVariable:(NSString *)name {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogDebug(@"Forwarding method argument variable registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject appendMethodArgumentVariable:name];
}

#pragma mark - Enumerations

- (void)beginEnumeration {
	LogVerbose(@"Starting enumeration...");
	EnumInfo *info = [[EnumInfo alloc] initWithRegistrar:self];
	info.sourceToken = self.currentSourceInfo;
	[self.storeEnumerations addObject:info];
	[self pushRegistrationObject:info];
}

- (void)appendEnumerationName:(NSString *)name {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogDebug(@"Forwarding enumeration name registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject appendEnumerationName:name];
}

- (void)appendEnumerationItem:(NSString *)name {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogDebug(@"Forwarding enumeration item registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject appendEnumerationItem:name];
}

- (void)appendEnumerationValue:(NSString *)value {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogDebug(@"Forwarding enumeration value registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject appendEnumerationValue:value];
}

#pragma mark - Structs

- (void)beginStruct {
	LogVerbose(@"Starting C struct...");
	StructInfo *info = [[StructInfo alloc] initWithRegistrar:self];
	info.sourceToken = self.currentSourceInfo;
	[self.storeStructs addObject:info];
	[self pushRegistrationObject:info];
}

- (void)appendStructName:(NSString *)name {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogVerbose(@"Forwarding struct name registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject appendStructName:name];
}

#pragma mark - Constants

- (void)beginConstant {
	if ([self doesCurrentRegistrationObjectRespondTo:_cmd]) {
		LogDebug(@"Forwarding constant registration to %@...", self.currentRegistrationObject);
		[self.currentRegistrationObject beginConstant];
		return;
	}
	LogVerbose(@"Starting constant...");
	ConstantInfo *info = [[ConstantInfo alloc] initWithRegistrar:self];
	info.sourceToken = self.currentSourceInfo;
	[self.storeConstants addObject:info];
	[self pushRegistrationObject:info];
}

- (void)beginConstantTypes {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogDebug(@"Forwarding constant types registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject beginConstantTypes];
}

- (void)beginConstantDescriptors {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogDebug(@"Forwarding constant descriptors registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject beginConstantDescriptors];
}

- (void)appendConstantName:(NSString *)name {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogDebug(@"Forwarding constant name registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject appendConstantName:name];
}

#pragma mark - General objects

- (void)appendType:(NSString *)type {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogDebug(@"Forwarding type registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject appendType:type];
}

- (void)appendAttribute:(NSString *)attribute {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogDebug(@"Forwarding attribute registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject appendAttribute:attribute];
}

- (void)appendDescriptor:(NSString *)descriptor {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogDebug(@"Forwarding descriptor registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject appendDescriptor:descriptor];
}

#pragma mark - Comments

- (void)appendCommentToPreviousObject:(NSString *)comment {
	id object = self.lastPoppedRegistrationObject;
	if (!object) {
		LogWarn(@"No previous object, can't register comment!");
		return;
	}
	if (![object respondsToSelector:@selector(setComment:)]) {
		LogWarn(@"%@ doesn't respond to setComment:, can't register comment!", object);
		return;
	}
	[self createCommentFromText:comment registerTo:object];
}

- (void)appendCommentToNextObject:(NSString *)comment {
	LogDebug(@"Storing comment %@ for next object...", [comment gb_description]);
	self.commentTextForNextObject = comment;
}

#pragma mark - Finalizing registration for current object

- (void)endCurrentObject {
	if ([self doesPreviousRegistrationObjectRespondTo:_cmd]) {
		LogDebug(@"Forwarding end current object to %@...", self.previousRegistrationObject);
		[self.previousRegistrationObject endCurrentObject];
	}
	LogVerbose(@"Finalizing %@...", self.currentRegistrationObject);
	[self popRegistrationObject];
}

- (void)cancelCurrentObject {
	// Note that we must forward to object that's currently handling a child, hence previous registration object! However if there's only single object available, it's one of the top-level objects, so we should remove it from our arrays.
	if ([self doesPreviousRegistrationObjectRespondTo:_cmd]) {
		LogDebug(@"Forwarding cancel current object to %@...", self.previousRegistrationObject);
		[self.previousRegistrationObject cancelCurrentObject];
	} else if (self.currentRegistrationObject) {
		LogVerbose(@"Cancelling %@...", self.currentRegistrationObject);
		if ([self.currentRegistrationObject isKindOfClass:[ClassInfo class]]) {
			LogDebug(@"Removing from classes array...");
			[self.storeClasses removeLastObject];
		} else if ([self.currentRegistrationObject isKindOfClass:[CategoryInfo class]]) {
			if ([self.currentRegistrationObject isExtension]) {
				LogDebug(@"Removing from extensions array...");
				[self.storeExtensions removeLastObject];
			} else {
				LogDebug(@"Removing from categories array...");
				[self.storeCategories removeLastObject];
			}
		} else if ([self.currentRegistrationObject isKindOfClass:[ProtocolInfo class]]) {
			LogDebug(@"Removing from protocols array...");
			[self.storeProtocols removeLastObject];
		} else if ([self.currentRegistrationObject isKindOfClass:[EnumInfo class]]) {
			LogDebug(@"Removing from enumerations array...");
			[self.storeEnumerations removeLastObject];
		} else if ([self.currentRegistrationObject isKindOfClass:[StructInfo class]]) {
			LogDebug(@"Removing from structs array...");
			[self.storeStructs removeLastObject];
		} else if ([self.currentRegistrationObject isKindOfClass:[ConstantInfo class]]) {
			LogDebug(@"Removing from constants array...");
			[self.storeConstants removeLastObject];
		}
	}
	LogDebug(@"Popping object from registration stack...");
	[self popRegistrationObject];
}

@end
