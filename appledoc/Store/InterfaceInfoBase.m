//
//  InterfaceInfoBase.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/12/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "StoreConstants.h"
#import "StoreRegistrations.h"
#import "ObjectLinkData.h"
#import "MethodGroupInfo.h"
#import "PropertyInfo.h"
#import "MethodInfo.h"
#import "InterfaceInfoBase.h"

@interface InterfaceInfoBase ()
@property (nonatomic, strong) NSMutableArray *interfaceMethodsAndPropertiesInRegistrationOrder; // only used for nicer debug output!
@end

#pragma mark - 

@implementation InterfaceInfoBase

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
	LogIntDebug(@"Initializing adopted protocols array due to first access...");
	_interfaceAdoptedProtocols = [[NSMutableArray alloc] init];
	return _interfaceAdoptedProtocols;
}

- (NSMutableArray *)interfaceMethodGroups {
	if (_interfaceMethodGroups) return _interfaceMethodGroups;
	LogIntDebug(@"Initializing method groups array due to first access...");
	_interfaceMethodGroups = [[NSMutableArray alloc] init];
	return _interfaceMethodGroups;
}

- (NSMutableArray *)interfaceProperties {
	if (_interfaceProperties) return _interfaceProperties;
	LogIntDebug(@"Initializing properties array due to first access...");
	_interfaceProperties = [[NSMutableArray alloc] init];
	return _interfaceProperties;
}

- (NSMutableArray *)interfaceInstanceMethods {
	if (_interfaceInstanceMethods) return _interfaceInstanceMethods;
	LogIntDebug(@"Initializing instance methods array due to first access...");
	_interfaceInstanceMethods = [[NSMutableArray alloc] init];
	return _interfaceInstanceMethods;
}

- (NSMutableArray *)interfaceClassMethods {
	if (_interfaceClassMethods) return _interfaceClassMethods;
	LogIntDebug(@"Initializing class methods array due to first access...");
	_interfaceClassMethods = [[NSMutableArray alloc] init];
	return _interfaceClassMethods;
}

- (NSMutableArray *)interfaceMethodsAndPropertiesInRegistrationOrder {
	if (_interfaceMethodsAndPropertiesInRegistrationOrder) return _interfaceMethodsAndPropertiesInRegistrationOrder;
	LogIntDebug(@"Initializing methods and properties array due to first access...");
	_interfaceMethodsAndPropertiesInRegistrationOrder = [[NSMutableArray alloc] init];
	return _interfaceMethodsAndPropertiesInRegistrationOrder;
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

- (void)appendMethodGroupWithDescription:(NSString *)description {
	LogStoInfo(@"Starting method group...");
	MethodGroupInfo *data = [MethodGroupInfo MethodGroupInfoWithName:description];
	[self.interfaceMethodGroups addObject:data];
}

#pragma mark - Properties

- (void)beginPropertyDefinition {
	LogStoInfo(@"Starting property definition...");
	PropertyInfo *info = [[PropertyInfo alloc] initWithRegistrar:self.objectRegistrar];
	info.sourceToken = self.currentSourceInfo;
	[[self.interfaceMethodGroups.lastObject methodGroupMethods] addObject:info];
	[self.interfaceMethodsAndPropertiesInRegistrationOrder addObject:info];
	[self.interfaceProperties addObject:info];
	[self pushRegistrationObject:info];
}

#pragma mark - Methods

- (void)beginMethodDefinitionWithType:(NSString *)type {
	LogStoInfo(@"Starting %@ definition...", type);
	NSMutableArray *methodsArray = [self methodsArrayForType:type];
	if (!methodsArray) LogWarn(@"Unsupported method type %@!", type);
	MethodInfo *info = [[MethodInfo alloc] initWithRegistrar:self.objectRegistrar];
	info.sourceToken = self.currentSourceInfo;
	info.methodType = type;
	[[self.interfaceMethodGroups.lastObject methodGroupMethods] addObject:info];
	[self.interfaceMethodsAndPropertiesInRegistrationOrder addObject:info];
	[[self methodsArrayForType:type] addObject:info];
	[self pushRegistrationObject:info];
}

#pragma mark - Finalizing registration for current object

- (void)cancelCurrentObject {
	if ([self.currentRegistrationObject isKindOfClass:[PropertyInfo class]]) {
		LogStoInfo(@"Cancelling current property info!");
		MethodGroupInfo *lastMethodGroup = [self.interfaceMethodGroups lastObject];
		if ([lastMethodGroup.methodGroupMethods lastObject] == self.currentRegistrationObject) {
			LogStoDebug(@"Removing property info from last method group!");
			[lastMethodGroup.methodGroupMethods removeLastObject];
		}
		[self.interfaceProperties removeLastObject];
		[self.interfaceMethodsAndPropertiesInRegistrationOrder removeLastObject];
	} else if ([self.currentRegistrationObject isKindOfClass:[MethodInfo class]]) {
		LogStoInfo(@"Cancelling current method info!");
		MethodGroupInfo *lastMethodGroup = [self.interfaceMethodGroups lastObject];
		if ([lastMethodGroup.methodGroupMethods lastObject] == self.currentRegistrationObject) {
			LogStoDebug(@"Removing method info from last method group!");
			[lastMethodGroup.methodGroupMethods removeLastObject];
		}
		NSString *type = [self.currentRegistrationObject methodType];
		NSMutableArray *methodsArray = [self methodsArrayForType:type];
		if (!methodsArray) LogWarn(@"Unsupported method type %@!", type);
		[methodsArray removeLastObject];
		[self.interfaceMethodsAndPropertiesInRegistrationOrder removeLastObject];
	} else {
		LogWarn(@"Unknown context for cancel current object (%@)!", self.currentRegistrationObject);
	}
}

@end

#pragma mark - 

@implementation InterfaceInfoBase (Logging)

- (NSString *)description {
	NSMutableString *result = [NSMutableString string];
	if (_interfaceAdoptedProtocols && self.interfaceAdoptedProtocols.count > 0) {
		[result appendString:@" <"];
		[self.interfaceAdoptedProtocols enumerateObjectsUsingBlock:^(ObjectLinkData *data, NSUInteger idx, BOOL *stop) {
			if (idx > 0) [result appendString:@","];
			[result appendString:data.nameOfObject];
		}];
		[result appendString:@">"];
	}
	if (_interfaceMethodsAndPropertiesInRegistrationOrder && self.interfaceMethodsAndPropertiesInRegistrationOrder.count > 0) {
		[result appendString:@"\n"];
		[self.interfaceMethodsAndPropertiesInRegistrationOrder enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			[result appendFormat:@"%@\n", obj];
		}];
	}
	[result appendString:@"@end"];
	return result;
}

@end
