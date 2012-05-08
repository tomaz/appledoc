//
//  Store.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/19/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "Store.h"

@interface Store ()
- (BOOL)doesPreviousRegistrationObjectRespondTo:(SEL)selector;
@property (nonatomic, readonly) id previousRegistrationObject;
@property (nonatomic, strong) PKToken *currentSourceInfo;
@property (nonatomic, strong) NSMutableArray *registrationStack;
@end

#pragma mark - 

@implementation Store

@synthesize storeClasses = _storeClasses;
@synthesize storeExtensions = _storeExtensions;
@synthesize storeCategories = _storeCategories;
@synthesize storeProtocols = _storeProtocols;
@synthesize storeEnumerations = _storeEnumerations;
@synthesize storeStructs = _storeStructs;
@synthesize storeConstants = _storeConstants;
@synthesize currentSourceInfo = _currentSourceInfo;
@synthesize registrationStack = _registrationStack;

#pragma mark - StoreRegistrar and related stuff

- (BOOL)expectCurrentRegistrationObjectRespondTo:(SEL)selector {
	if (self.registrationStack.count == 0) {
		LogStoWarn(@"Expecting at least one object responding to %@ on registration stack!", NSStringFromSelector(selector));
		return NO;
	}
	if (![self.currentRegistrationObject respondsToSelector:selector]) {
		LogStoWarn(@"Current object %@ on registration stack doesn't respond to %@!", self.currentRegistrationObject, NSStringFromSelector(selector));
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
	LogStoDebug(@"Pushing object %@ to registration stack...", object);
	[self.registrationStack addObject:object];
}

- (id)popRegistrationObject {
	id result = self.currentRegistrationObject;
	[self.registrationStack removeLastObject];
	return result;
}

- (id)currentRegistrationObject {
	return [self.registrationStack lastObject];
}

- (id)previousRegistrationObject {
	if (self.registrationStack.count < 2) return nil;
	NSUInteger index = self.registrationStack.count - 2;
	return [self.registrationStack objectAtIndex:index];
}

- (NSMutableArray *)registrationStack {
	if (_registrationStack) return _registrationStack;
	LogIntDebug(@"Initializing registration stack due to first access...");
	_registrationStack = [[NSMutableArray alloc] init];
	return _registrationStack;
}

#pragma mark - Properties

- (NSMutableArray *)storeClasses {
	if (_storeClasses) return _storeClasses;
	LogIntDebug(@"Initializing store classes array due to first access...");
	_storeClasses = [[NSMutableArray alloc] init];
	return _storeClasses;
}

- (NSMutableArray *)storeExtensions {
	if (_storeExtensions) return _storeExtensions;
	LogIntDebug(@"Initializing store extensions array due to first access...");
	_storeExtensions = [[NSMutableArray alloc] init];
	return _storeExtensions;
}

- (NSMutableArray *)storeCategories {
	if (_storeCategories) return _storeCategories;
	LogIntDebug(@"Initializing store categories array due to first access...");
	_storeCategories = [[NSMutableArray alloc] init];
	return _storeCategories;
}

- (NSMutableArray *)storeProtocols {
	if (_storeProtocols) return _storeProtocols;
	LogIntDebug(@"Initializing store protocols array due to first access...");
	_storeProtocols = [[NSMutableArray alloc] init];
	return _storeProtocols;
}

- (NSMutableArray *)storeEnumerations {
	if (_storeEnumerations) return _storeEnumerations;
	LogIntDebug(@"Initializing store enumerations array due to first access...");
	_storeEnumerations = [[NSMutableArray alloc] init];
	return _storeEnumerations;
}

- (NSMutableArray *)storeStructs {
	if (_storeStructs) return _storeStructs;
	LogIntDebug(@"Initializing store structs array due to first access...");
	_storeStructs = [[NSMutableArray alloc] init];
	return _storeStructs;
}

- (NSMutableArray *)storeConstants {
	if (_storeConstants) return _storeConstants;
	LogIntDebug(@"Initializing store constants array due to first access...");
	_storeConstants = [[NSMutableArray alloc] init];
	return _storeConstants;
}

@end

#pragma mark - 

@implementation Store (Registrations)

#pragma mark - Classes, categories and protocols handling

- (void)beginClassWithName:(NSString *)name derivedFromClassWithName:(NSString *)derived {
	LogStoInfo(@"Starting class %@ derived from %@...", name, derived);
	ClassInfo *info = [[ClassInfo alloc] initWithRegistrar:self];
	info.nameOfClass = name;
	info.nameOfSuperClass = derived;
	[self.storeClasses addObject:info];
	[self pushRegistrationObject:info];
}

- (void)beginExtensionForClassWithName:(NSString *)name {
	LogStoInfo(@"Starting class extenstion for class %@...", name);
	CategoryInfo *info = [[CategoryInfo alloc] initWithRegistrar:self];
	info.nameOfClass = name;
	info.nameOfCategory = nil;
	[self.storeExtensions addObject:info];
	[self pushRegistrationObject:info];
}

- (void)beginCategoryWithName:(NSString *)category forClassWithName:(NSString *)name {
	LogStoInfo(@"Starting category %@ for class %@...", category, name);
	CategoryInfo *info = [[CategoryInfo alloc] initWithRegistrar:self];
	info.nameOfClass = name;
	info.nameOfCategory = category;
	[self.storeCategories addObject:info];
	[self pushRegistrationObject:info];
}

- (void)beginProtocolWithName:(NSString *)name {
	LogStoInfo(@"Starting protocol %@...", name);
	ProtocolInfo *info = [[ProtocolInfo alloc] initWithRegistrar:self];
	info.nameOfProtocol = name;
	[self.storeProtocols addObject:info];
	[self pushRegistrationObject:info];
}

- (void)appendAdoptedProtocolWithName:(NSString *)name {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogStoDebug(@"Forwarding adopted protocol registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject appendAdoptedProtocolWithName:name];
}

#pragma mark - Method groups

- (void)appendMethodGroupWithDescription:(NSString *)description {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogStoDebug(@"Forwarding method group description registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject appendMethodGroupWithDescription:description];
}

#pragma mark - Properties

- (void)beginPropertyDefinition {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogStoDebug(@"Forwarding property definition registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject beginPropertyDefinition];
}

- (void)beginPropertyAttributes {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogStoDebug(@"Forwarding property attributes registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject beginPropertyAttributes];
}

- (void)beginPropertyTypes {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogStoDebug(@"Forwarding property types registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject beginPropertyTypes];
}

- (void)beginPropertyDescriptors {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogStoDebug(@"Forwarding property descriptors registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject beginPropertyDescriptors];
}

- (void)appendPropertyName:(NSString *)name {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogStoDebug(@"Forwarding property name registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject appendPropertyName:name];
}

#pragma mark - Methods

- (void)beginMethodDefinitionWithType:(NSString *)type {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogStoDebug(@"Forwarding method definition registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject beginMethodDefinitionWithType:type];
}

- (void)beginMethodResults {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogStoDebug(@"Forwarding method results registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject beginMethodResults];
}

- (void)beginMethodArgument {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogStoDebug(@"Forwarding method arguments registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject beginMethodArgument];
}

- (void)beginMethodArgumentTypes {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogStoDebug(@"Forwarding method argument types registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject beginMethodArgumentTypes];
}

- (void)beginMethodDescriptors {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogStoDebug(@"Forwarding method descriptors registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject beginMethodDescriptors];
}

- (void)appendMethodArgumentSelector:(NSString *)name {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogStoDebug(@"Forwarding method argument selector registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject appendMethodArgumentSelector:name];
}

- (void)appendMethodArgumentVariable:(NSString *)name {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogStoDebug(@"Forwarding method argument variable registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject appendMethodArgumentVariable:name];
}

#pragma mark - Enumerations

- (void)beginEnumeration {
	LogStoInfo(@"Starting enumeration...");
	EnumInfo *info = [[EnumInfo alloc] initWithRegistrar:self];
	[self.storeEnumerations addObject:info];
	[self pushRegistrationObject:info];
}

- (void)appendEnumerationItem:(NSString *)name {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogStoDebug(@"Forwarding enumeration item registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject appendEnumerationItem:name];
}

- (void)appendEnumerationValue:(NSString *)value {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogStoDebug(@"Forwarding enumeration value registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject appendEnumerationValue:value];
}

#pragma mark - Structs

- (void)beginStruct {
	LogStoInfo(@"Starting C struct...");
	StructInfo *info = [[StructInfo alloc] initWithRegistrar:self];
	[self.storeStructs addObject:info];
	[self pushRegistrationObject:info];
}

- (void)appendStructName:(NSString *)name {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogStoVerbose(@"Forwarding struct name registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject appendStructName:name];
}

#pragma mark - Constants

- (void)beginConstant {
	if ([self doesCurrentRegistrationObjectRespondTo:_cmd]) {
		LogStoDebug(@"Forwarding constant registration to %@...", self.currentRegistrationObject);
		[self.currentRegistrationObject beginConstant];
		return;
	}
	LogStoInfo(@"Starting constant...");
	ConstantInfo *info = [[ConstantInfo alloc] initWithRegistrar:self];
	[self.storeConstants addObject:info];
	[self pushRegistrationObject:info];
}

- (void)beginConstantTypes {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogStoDebug(@"Forwarding constant types registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject beginConstantTypes];
}

- (void)beginConstantDescriptors {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogStoDebug(@"Forwarding constant descriptors registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject beginConstantDescriptors];
}

- (void)appendConstantName:(NSString *)name {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogStoDebug(@"Forwarding constant name registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject appendConstantName:name];
}

#pragma mark - General objects

- (void)appendType:(NSString *)type {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogStoDebug(@"Forwarding type registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject appendType:type];
}

- (void)appendAttribute:(NSString *)attribute {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogStoDebug(@"Forwarding attribute registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject appendAttribute:attribute];
}

- (void)appendDescriptor:(NSString *)descriptor {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogStoDebug(@"Forwarding descriptor registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject appendDescriptor:descriptor];
}

#pragma mark - Finalizing registration for current object

- (void)endCurrentObject {
	if ([self doesPreviousRegistrationObjectRespondTo:_cmd]) {
		LogStoDebug(@"Forwarding end current object to %@...", self.previousRegistrationObject);
		[self.previousRegistrationObject endCurrentObject];
	}
	LogStoInfo(@"Finalizing %@...", self.currentRegistrationObject);
	[self popRegistrationObject];
}

- (void)cancelCurrentObject {
	// Note that we must forward to object that's currently handling a child, hence previous registration object! However if there's only single object available, it's one of the top-level objects, so we should remove it from our arrays.
	if ([self doesPreviousRegistrationObjectRespondTo:_cmd]) {
		LogStoDebug(@"Forwarding cancel current object to %@...", self.previousRegistrationObject);
		[self.previousRegistrationObject cancelCurrentObject];
	} else if (self.currentRegistrationObject) {
		LogStoInfo(@"Cancelling %@...", self.currentRegistrationObject);
		if ([self.currentRegistrationObject isKindOfClass:[ClassInfo class]]) {
			LogStoDebug(@"Removing from classes array...");
			[self.storeClasses removeLastObject];
		} else if ([self.currentRegistrationObject isKindOfClass:[CategoryInfo class]]) {
			if ([self.currentRegistrationObject isExtension]) {
				LogStoDebug(@"Removing from extensions array...");
				[self.storeExtensions removeLastObject];
			} else {
				LogStoDebug(@"Removing from categories array...");
				[self.storeCategories removeLastObject];
			}
		} else if ([self.currentRegistrationObject isKindOfClass:[ProtocolInfo class]]) {
			LogStoDebug(@"Removing from protocols array...");
			[self.storeProtocols removeLastObject];
		} else if ([self.currentRegistrationObject isKindOfClass:[EnumInfo class]]) {
			LogStoDebug(@"Removing from enumerations array...");
			[self.storeEnumerations removeLastObject];
		} else if ([self.currentRegistrationObject isKindOfClass:[StructInfo class]]) {
			LogStoDebug(@"Removing from structs array...");
			[self.storeStructs removeLastObject];
		} else if ([self.currentRegistrationObject isKindOfClass:[ConstantInfo class]]) {
			LogStoDebug(@"Removing from constants array...");
			[self.storeConstants removeLastObject];
		}
	}
	LogStoDebug(@"Popping object from registration stack...");
	[self popRegistrationObject];
}

@end
