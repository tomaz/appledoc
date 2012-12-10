//
//  LinkKnownObjectsTask.m
//  appledoc
//
//  Created by Tomaz Kragelj on 7.12.12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "Store.h"
#import "LinkKnownObjectsTask.h"

@implementation LinkKnownObjectsTask

- (GBResult)runTask {
	LogDebug(@"Preparing links to known objects...");
	[self handleClassesFromStore:self.store];
	[self handleExtensionsFromStore:self.store];
	[self handleCategoriesFromStore:self.store];
	[self handleProtocolsFromStore:self.store];
	return GBResultOk;
}

#pragma mark - Top level objects handling

- (void)handleClassesFromStore:(Store *)store {
	LogDebug(@"Preparing links for classes...");
	__weak LinkKnownObjectsTask *bself = self;
	[store.storeClasses enumerateObjectsUsingBlock:^(ClassInfo *class, NSUInteger idx, BOOL *stop) {
		LogDebug(@"Handling %@...", class);
		if (class.nameOfSuperClass > 0) {
			[store.storeClasses enumerateObjectsUsingBlock:^(ClassInfo *testedClass, NSUInteger testedIdx, BOOL *testStop) {
				if (testedClass == class) return;
				if (![testedClass.nameOfClass isEqualToString:class.nameOfSuperClass]) return;
				LogDebug(@"Found link to super class %@.", testedClass);
				class.classSuperClass.linkToObject = testedClass;
			}];
		}
		[bself handleAdoptedProtocolsForInterface:class store:store];
	}];
}

- (void)handleExtensionsFromStore:(Store *)store {
	LogDebug(@"Preparing links for classes...");
	__weak LinkKnownObjectsTask *bself = self;
	[store.storeExtensions enumerateObjectsUsingBlock:^(CategoryInfo *class, NSUInteger idx, BOOL *stop) {
		LogDebug(@"Handling %@...", class);
		[bself handleAdoptedProtocolsForInterface:class store:store];
	}];
}

- (void)handleCategoriesFromStore:(Store *)store {
	LogDebug(@"Preparing links for classes...");
	__weak LinkKnownObjectsTask *bself = self;
	[store.storeCategories enumerateObjectsUsingBlock:^(CategoryInfo *class, NSUInteger idx, BOOL *stop) {
		LogDebug(@"Handling %@...", class);
		[bself handleAdoptedProtocolsForInterface:class store:store];
	}];
}

- (void)handleProtocolsFromStore:(Store *)store {
	LogDebug(@"Preparing links for classes...");
	__weak LinkKnownObjectsTask *bself = self;
	[store.storeProtocols enumerateObjectsUsingBlock:^(ProtocolInfo *class, NSUInteger idx, BOOL *stop) {
		LogDebug(@"Handling %@...", class);
		[bself handleAdoptedProtocolsForInterface:class store:store];
	}];
}

#pragma mark - Common functionality

- (void)handleAdoptedProtocolsForInterface:(InterfaceInfoBase *)interface store:(Store *)store {
	LogDebug(@"Handling adopted protocols...");
	[interface.interfaceAdoptedProtocols enumerateObjectsUsingBlock:^(ObjectLinkInfo *link, NSUInteger idx, BOOL *stop) {
		[store.storeProtocols enumerateObjectsUsingBlock:^(ProtocolInfo *protocol, NSUInteger idx, BOOL *stop) {
			if (![protocol.nameOfProtocol isEqualToString:link.nameOfObject]) return;
			LogDebug(@"Found link to %@.", protocol);
			link.linkToObject = protocol;
			*stop = YES;
		}];
	}];
}

@end
