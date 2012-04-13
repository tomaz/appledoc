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
@end

#pragma mark - 

@implementation Store

@synthesize currentSourceInfo = _currentSourceInfo;

@end

#pragma mark - 

@implementation Store (Registrations)

#pragma mark - Classes, categories and protocols handling

- (void)beginClassWithName:(NSString *)name derivedFromClassWithName:(NSString *)derived {
	LogStoInfo(@"Starting class %@ derived from %@...", name, derived);
	ClassInfo *info = [[ClassInfo alloc] init];
	info.nameOfClass = name;
	info.nameOfSuperClass = derived;
	[self pushRegistrationObject:info];
}

- (void)beginExtensionForClassWithName:(NSString *)name {
	LogStoInfo(@"Starting class extenstion for class %@...", name);
	CategoryInfo *info = [[CategoryInfo alloc] init];
	info.nameOfClass = name;
	info.nameOfCategory = nil;
	[self pushRegistrationObject:info];
}

- (void)beginCategoryWithName:(NSString *)category forClassWithName:(NSString *)name {
	LogStoInfo(@"Starting category %@ for class %@...", category, name);
	CategoryInfo *info = [[CategoryInfo alloc] init];
	info.nameOfClass = name;
	info.nameOfCategory = category;
	[self pushRegistrationObject:info];
}

- (void)beginProtocolWithName:(NSString *)name {
	LogStoInfo(@"Starting protocol %@...", name);
	ProtocolInfo *info = [[ProtocolInfo alloc] init];
	info.nameOfProtocol = name;
	[self pushRegistrationObject:info];
}

- (void)appendAdoptedProtocolWithName:(NSString *)name {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	[self.currentRegistrationObject appendAdoptedProtocolWithName:name];
}

#pragma mark - Method groups

- (void)beginMethodGroup {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	[self.currentRegistrationObject beginMethodGroup];
}

- (void)appendMethodGroupDescription:(NSString *)description {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	[self.currentRegistrationObject appendMethodGroupDescription:description];
}

#pragma mark - Properties

- (void)beginPropertyDefinition {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	[self.currentRegistrationObject beginPropertyDefinition];
}

- (void)beginPropertyAttributes {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	[self.currentRegistrationObject beginPropertyAttributes];
}

- (void)appendPropertyName:(NSString *)name {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	[self.currentRegistrationObject appendPropertyName:name];
}

#pragma mark - Methods

- (void)beginMethodDefinition {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	[self.currentRegistrationObject beginMethodDefinition];
}

- (void)appendMethodType:(NSString *)type {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	[self.currentRegistrationObject appendMethodType:type];
}

- (void)beginMethodArgument {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	[self.currentRegistrationObject beginMethodArgument];
}

- (void)appendMethodArgumentSelector:(NSString *)name {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	[self.currentRegistrationObject appendMethodArgumentSelector:name];
}

- (void)appendMethodArgumentVariable:(NSString *)name {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
	[self.currentRegistrationObject appendMethodArgumentVariable:name];
}

#pragma mark - Enumerations

- (void)beginEnumeration {
	LogStoInfo(@"Starting enumeration...");
}

- (void)appendEnumerationItem:(NSString *)name {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
}

- (void)appendEnumerationValue:(NSString *)value {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
}

#pragma mark - Structs

- (void)beginStruct {
	LogStoInfo(@"Starting C struct...");
}

#pragma mark - Constants

- (void)beginConstant {
	LogStoInfo(@"Starting constant...");
}

- (void)appendConstantType:(NSString *)type {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
}

- (void)appendConstantName:(NSString *)name {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
}

#pragma mark - General objects

- (void)beginTypeDefinition {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
}

- (void)appendType:(NSString *)type {
	if (![self expectCurrentRegistrationObjectRespondTo:_cmd]) return;
}

#pragma mark - Finalizing registration for current object

- (void)endCurrentObject {
	if (self.registrationStack.count > 0 && [self.currentRegistrationObject respondsToSelector:_cmd]) {
		LogStoDebug(@"Forwarding end current object to %@...", self.currentRegistrationObject);
		[self.currentRegistrationObject endCurrentObject];
	}
	LogStoInfo(@"Finalizing current object...");
	[self popRegistrationObject];
}

- (void)cancelCurrentObject {
	if (self.registrationStack.count > 0 && [self.currentRegistrationObject respondsToSelector:_cmd]) {
		LogStoDebug(@"Forwarding cancel current object to %@...", self.currentRegistrationObject);
		[self.currentRegistrationObject cancelCurrentObject];
	}
	LogStoInfo(@"Cancelling current object...");
	[self popRegistrationObject];
}

@end
