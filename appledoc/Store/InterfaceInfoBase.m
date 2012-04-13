//
//  InterfaceInfoBase.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/12/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "ObjectLinkData.h"
#import "MethodGroupData.h"
#import "InterfaceInfoBase.h"

@implementation InterfaceInfoBase

@synthesize interfaceAdoptedProtocols = _interfaceAdoptedProtocols;
@synthesize interfaceMethodGroups = _interfaceMethodGroups;

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
		LogStoWarn(@"Unknown context for method group description (%@)!", self.currentRegistrationObject);
		return;
	}
	[self.currentRegistrationObject setNameOfMethodGroup:description];
}

#pragma mark - Properties

- (void)beginPropertyDefinition {
	LogStoInfo(@"Starting property definition...");
}

- (void)beginPropertyAttributes {
	LogStoInfo(@"Starting property attributes...");
}

- (void)appendPropertyName:(NSString *)name {
}

#pragma mark - Methods

- (void)beginMethodDefinition {
	LogStoInfo(@"Starting method definition...");
}

- (void)appendMethodType:(NSString *)type {
}

- (void)beginMethodArgument {
	LogStoVerbose(@"Starting method argument...");
}

- (void)appendMethodArgumentSelector:(NSString *)name {
}

- (void)appendMethodArgumentVariable:(NSString *)name {
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
	} else {
		LogStoDebug(@"Unknown context for cancel current object (%@)!", self.currentRegistrationObject);
	}
	[self popRegistrationObject];
}

@end
