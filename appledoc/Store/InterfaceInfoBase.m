//
//  InterfaceInfoBase.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/12/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "StoreConstants.h"
#import "ObjectLinkData.h"
#import "MethodGroupData.h"
#import "PropertyInfo.h"
#import "MethodInfo.h"
#import "InterfaceInfoBase.h"

@interface InterfaceInfoBase ()
- (NSMutableArray *)methodsArrayForType:(NSString *)type;
@end

#pragma mark - 

@implementation InterfaceInfoBase

@synthesize interfaceAdoptedProtocols = _interfaceAdoptedProtocols;
@synthesize interfaceMethodGroups = _interfaceMethodGroups;
@synthesize interfaceProperties = _interfaceProperties;
@synthesize interfaceInstanceMethods = _interfaceInstanceMethods;
@synthesize interfaceClassMethods = _interfaceClassMethods;

#pragma mark - Helper methods

- (NSMutableArray *)methodsArrayForType:(NSString *)type {
	if (type == GBStoreTypes.classMethod)
		return self.interfaceClassMethods;
	else if (type == GBStoreTypes.instanceMethod)
		return self.interfaceInstanceMethods;
	return nil;
}

#pragma mark - Properties

- (NSMutableArray *)interfaceAdoptedProtocols {
	if (_interfaceAdoptedProtocols) return _interfaceAdoptedProtocols;
	LogStoDebug(@"Initializing adopted protocols array due to first access...");
	_interfaceAdoptedProtocols = [[NSMutableArray alloc] init];
	return _interfaceAdoptedProtocols;
}

- (NSMutableArray *)interfaceMethodGroups {
	if (_interfaceMethodGroups) return _interfaceMethodGroups;
	LogStoDebug(@"Initializing method groups array due to first access...");
	_interfaceMethodGroups = [[NSMutableArray alloc] init];
	return _interfaceMethodGroups;
}

- (NSMutableArray *)interfaceProperties {
	if (_interfaceProperties) return _interfaceProperties;
	LogStoDebug(@"Initializing properties array due to first access...");
	_interfaceProperties = [[NSMutableArray alloc] init];
	return _interfaceProperties;
}

- (NSMutableArray *)interfaceInstanceMethods {
	if (_interfaceInstanceMethods) return _interfaceInstanceMethods;
	LogStoDebug(@"Initializing instance methods array due to first access...");
	_interfaceInstanceMethods = [[NSMutableArray alloc] init];
	return _interfaceInstanceMethods;
}

- (NSMutableArray *)interfaceClassMethods {
	if (_interfaceClassMethods) return _interfaceClassMethods;
	LogStoDebug(@"Initializing class methods array due to first access...");
	_interfaceClassMethods = [[NSMutableArray alloc] init];
	return _interfaceClassMethods;
}

@end

#pragma mark - 

@implementation InterfaceInfoBase (Registrations)

#pragma mark - Interface level registrations

- (void)appendAdoptedProtocolWithName:(NSString *)name {
	LogStoVerbose(@"Appending adopted protocol %@...", name);
	if ([self.interfaceAdoptedProtocols gb_containsObjectLinkDataWithName:name]) {
		LogStoDebug(@"%@ is already in the adopted protocols list, ignoring...", name);
		return;
	}
	ObjectLinkData *data = [ObjectLinkData objectLinkDataWithName:name];
	[self.interfaceAdoptedProtocols addObject:data];
}

#pragma mark - Method groups

- (void)beginMethodGroup {
	LogStoInfo(@"Starting method group...");
	MethodGroupData *data = [MethodGroupData methodGroupDataWithName:nil];
	[self.interfaceMethodGroups addObject:data];
	[self pushRegistrationObject:data];
}

- (void)appendMethodGroupDescription:(NSString *)description {
	LogStoVerbose(@"Appending method group description '%@'...", description);
	if (![self.currentRegistrationObject isKindOfClass:[MethodGroupData class]]) {
		LogWarn(@"Unknown context for method group description (%@)!", self.currentRegistrationObject);
		return;
	}
	[self.currentRegistrationObject setNameOfMethodGroup:description];
}

#pragma mark - Properties

- (void)beginPropertyDefinition {
	LogStoInfo(@"Starting property definition...");
	PropertyInfo *info = [[PropertyInfo alloc] init];
	[[self.interfaceMethodGroups.lastObject methodGroupMethods] addObject:info];
	[self.interfaceProperties addObject:info];
	[self pushRegistrationObject:info];
}

#pragma mark - Methods

- (void)beginMethodDefinitionWithType:(NSString *)type {
	LogStoInfo(@"Starting %@ method definition...", type);
	NSMutableArray *methodsArray = [self methodsArrayForType:type];
	if (!methodsArray) LogWarn(@"Unsupported method type %@!", type);
	MethodInfo *info = [[MethodInfo alloc] init];
	info.methodType = type;
	[[self.interfaceMethodGroups.lastObject methodGroupMethods] addObject:info];
	[[self methodsArrayForType:type] addObject:info];
	[self pushRegistrationObject:info];
}

#pragma mark - Finalizing registration for current object

- (void)endCurrentObject {
	if ([self.currentRegistrationObject isKindOfClass:[MethodGroupData class]]) {
		LogStoVerbose(@"Ending current method group data...");
		MethodGroupData *data = (MethodGroupData *)self.currentRegistrationObject;
		if (data.methodGroupMethods.count == 0) {
			LogStoVerbose(@"Method group is empty, removing!");
			[self.interfaceMethodGroups removeObject:data];
		}
	}
	[self popRegistrationObject];
}

- (void)cancelCurrentObject {
	if ([self.currentRegistrationObject isKindOfClass:[MethodGroupData class]]) {
		LogStoInfo(@"Cancelling current method group data!");
		[self.interfaceMethodGroups removeObject:self.currentRegistrationObject];
	} else if ([self.currentRegistrationObject isKindOfClass:[PropertyInfo class]]) {
		LogStoInfo(@"Cancelling current property info!");
		MethodGroupData *lastMethodGroup = [self.interfaceMethodGroups lastObject];
		if ([lastMethodGroup.methodGroupMethods lastObject] == self.currentRegistrationObject) {
			LogStoDebug(@"Removing property info from last method group!");
			[lastMethodGroup.methodGroupMethods removeLastObject];
		}
		[self.interfaceProperties removeObject:self.currentRegistrationObject];
	} else if ([self.currentRegistrationObject isKindOfClass:[MethodInfo class]]) {
		LogStoInfo(@"Cancelling current method info!");
		MethodGroupData *lastMethodGroup = [self.interfaceMethodGroups lastObject];
		if ([lastMethodGroup.methodGroupMethods lastObject] == self.currentRegistrationObject) {
			LogStoDebug(@"Removing method info from last method group!");
			[lastMethodGroup.methodGroupMethods removeLastObject];
		}
		NSString *type = [self.currentRegistrationObject methodType];
		NSMutableArray *methodsArray = [self methodsArrayForType:type];
		if (!methodsArray) LogWarn(@"Unsupported method type %@!", type);
		[methodsArray removeLastObject];
	} else {
		LogStoVerbose(@"Unknown context for cancel current object (%@)!", self.currentRegistrationObject);
	}
	[self popRegistrationObject];
}

@end
