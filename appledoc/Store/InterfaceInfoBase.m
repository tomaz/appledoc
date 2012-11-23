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
#import "ObjectLinkInfo.h"
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
	LogDebug(@"Initializing adopted protocols array due to first access...");
	_interfaceAdoptedProtocols = [[NSMutableArray alloc] init];
	return _interfaceAdoptedProtocols;
}

- (NSMutableArray *)interfaceMethodGroups {
	if (_interfaceMethodGroups) return _interfaceMethodGroups;
	LogDebug(@"Initializing method groups array due to first access...");
	_interfaceMethodGroups = [[NSMutableArray alloc] init];
	return _interfaceMethodGroups;
}

- (NSMutableArray *)interfaceProperties {
	if (_interfaceProperties) return _interfaceProperties;
	LogDebug(@"Initializing properties array due to first access...");
	_interfaceProperties = [[NSMutableArray alloc] init];
	return _interfaceProperties;
}

- (NSMutableArray *)interfaceInstanceMethods {
	if (_interfaceInstanceMethods) return _interfaceInstanceMethods;
	LogDebug(@"Initializing instance methods array due to first access...");
	_interfaceInstanceMethods = [[NSMutableArray alloc] init];
	return _interfaceInstanceMethods;
}

- (NSMutableArray *)interfaceClassMethods {
	if (_interfaceClassMethods) return _interfaceClassMethods;
	LogDebug(@"Initializing class methods array due to first access...");
	_interfaceClassMethods = [[NSMutableArray alloc] init];
	return _interfaceClassMethods;
}

- (NSMutableArray *)interfaceMethodsAndPropertiesInRegistrationOrder {
	if (_interfaceMethodsAndPropertiesInRegistrationOrder) return _interfaceMethodsAndPropertiesInRegistrationOrder;
	LogDebug(@"Initializing methods and properties array due to first access...");
	_interfaceMethodsAndPropertiesInRegistrationOrder = [[NSMutableArray alloc] init];
	return _interfaceMethodsAndPropertiesInRegistrationOrder;
}

@end

#pragma mark - 

@implementation InterfaceInfoBase (Registrations)

#pragma mark - Interface level registrations

- (void)appendAdoptedProtocolWithName:(NSString *)name {
	LogVerbose(@"Appending adopted protocol %@...", name);
	if ([self.interfaceAdoptedProtocols gb_containsObjectLinkInfoWithName:name]) {
		LogDebug(@"%@ is already in the adopted protocols list, ignoring...", name);
		return;
	}
	ObjectLinkInfo *data = [ObjectLinkInfo ObjectLinkInfoWithName:name];
	[self.interfaceAdoptedProtocols addObject:data];
}

#pragma mark - Method groups

- (void)appendMethodGroupWithDescription:(NSString *)description {
	LogVerbose(@"Starting method group...");
	MethodGroupInfo *data = [MethodGroupInfo MethodGroupInfoWithName:description];
	[self.interfaceMethodGroups addObject:data];
}

#pragma mark - Properties

- (void)beginPropertyDefinition {
	LogVerbose(@"Starting property definition...");
	PropertyInfo *info = [[PropertyInfo alloc] initWithRegistrar:self.objectRegistrar];
	info.sourceToken = self.currentSourceInfo;
	[[self.interfaceMethodGroups.lastObject methodGroupMethods] addObject:info];
	[self.interfaceMethodsAndPropertiesInRegistrationOrder addObject:info];
	[self.interfaceProperties addObject:info];
	[self pushRegistrationObject:info];
}

#pragma mark - Methods

- (void)beginMethodDefinitionWithType:(NSString *)type {
	LogVerbose(@"Starting %@ definition...", type);
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
		LogVerbose(@"Cancelling current property info!");
		MethodGroupInfo *lastMethodGroup = [self.interfaceMethodGroups lastObject];
		if ([lastMethodGroup.methodGroupMethods lastObject] == self.currentRegistrationObject) {
			LogDebug(@"Removing property info from last method group!");
			[lastMethodGroup.methodGroupMethods removeLastObject];
		}
		[self.interfaceProperties removeLastObject];
		[self.interfaceMethodsAndPropertiesInRegistrationOrder removeLastObject];
	} else if ([self.currentRegistrationObject isKindOfClass:[MethodInfo class]]) {
		LogVerbose(@"Cancelling current method info!");
		MethodGroupInfo *lastMethodGroup = [self.interfaceMethodGroups lastObject];
		if ([lastMethodGroup.methodGroupMethods lastObject] == self.currentRegistrationObject) {
			LogDebug(@"Removing method info from last method group!");
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
	return [NSString gb_format:@"%lu properties, %lu interface methods, %lu class methods", self.interfaceProperties.count, self.interfaceInstanceMethods.count, self.interfaceClassMethods.count];
}

- (NSString *)debugDescription {
	NSMutableString *result = [NSMutableString string];
	if (_interfaceAdoptedProtocols && self.interfaceAdoptedProtocols.count > 0) {
		[result appendString:@" <"];
		[self.interfaceAdoptedProtocols enumerateObjectsUsingBlock:^(ObjectLinkInfo *data, NSUInteger idx, BOOL *stop) {
			if (idx > 0) [result appendString:@","];
			[result appendString:data.nameOfObject];
		}];
		[result appendString:@">"];
	}
	if (_interfaceMethodsAndPropertiesInRegistrationOrder && self.interfaceMethodsAndPropertiesInRegistrationOrder.count > 0) {
		[result appendString:@"\n"];
		[self.interfaceMethodsAndPropertiesInRegistrationOrder enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			[result appendFormat:@"%@\n", [obj debugDescription]];
		}];
	}
	[result appendString:@"@end"];
	return result;
}

@end
