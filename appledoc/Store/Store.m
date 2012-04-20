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

- (NSMutableArray *)registrationStack {
	if (_registrationStack) return _registrationStack;
	LogStoDebug(@"Initializing registration stack due to first access...");
	_registrationStack = [[NSMutableArray alloc] init];
	return _registrationStack;
}

#pragma mark - Properties

- (NSMutableArray *)storeClasses {
	if (_storeClasses) return _storeClasses;
	LogStoDebug(@"Initializing store classes array due to first access...");
	_storeClasses = [[NSMutableArray alloc] init];
	return _storeClasses;
}

- (NSMutableArray *)storeExtensions {
	if (_storeExtensions) return _storeExtensions;
	LogStoDebug(@"Initializing store extensions array due to first access...");
	_storeExtensions = [[NSMutableArray alloc] init];
	return _storeExtensions;
}

- (NSMutableArray *)storeCategories {
	if (_storeCategories) return _storeCategories;
	LogStoDebug(@"Initializing store categories array due to first access...");
	_storeCategories = [[NSMutableArray alloc] init];
	return _storeCategories;
}

- (NSMutableArray *)storeProtocols {
	if (_storeProtocols) return _storeProtocols;
	LogStoDebug(@"Initializing store protocols array due to first access...");
	_storeProtocols = [[NSMutableArray alloc] init];
	return _storeProtocols;
}

- (NSMutableArray *)storeEnumerations {
	if (_storeEnumerations) return _storeEnumerations;
	LogStoDebug(@"Initializing store enumerations array due to first access...");
	_storeEnumerations = [[NSMutableArray alloc] init];
	return _storeEnumerations;
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
	NSAssert(NO, @"Not implemented yet!");
}

#pragma mark - Constants

- (void)beginConstant {
	LogStoInfo(@"Starting constant...");
	NSAssert(NO, @"Not implemented yet!");
}

- (void)appendConstantType:(NSString *)type {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	LogStoDebug(@"Forwarding constant type registration to %@...", self.currentRegistrationObject);
	[self.currentRegistrationObject appendConstantType:type];
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

#pragma mark - Finalizing registration for current object

- (void)endCurrentObject {
	if ([self doesCurrentRegistrationObjectRespondTo:_cmd]) {
		LogStoDebug(@"Forwarding end current object to %@...", self.currentRegistrationObject);
		[self.currentRegistrationObject endCurrentObject];
	}
	LogStoInfo(@"Finalizing %@...", self.currentRegistrationObject);
	[self popRegistrationObject];
}

- (void)cancelCurrentObject {
	if ([self doesCurrentRegistrationObjectRespondTo:_cmd]) {
		LogStoDebug(@"Forwarding cancel current object to %@...", self.currentRegistrationObject);
		[self.currentRegistrationObject cancelCurrentObject];
	}
	LogStoInfo(@"Cancelling %@...", self.currentRegistrationObject);
	[self popRegistrationObject];
}

@end
