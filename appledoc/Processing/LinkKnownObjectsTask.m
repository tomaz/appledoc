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
	LogDebug(@"Handling classes...");
	__weak LinkKnownObjectsTask *bself = self;
	[store.storeClasses enumerateObjectsUsingBlock:^(ClassInfo *class, NSUInteger idx, BOOL *stop) {
		LogDebug(@"Handling %@...", class);
		[bself handleSuperClassesForClass:class store:store];
		[bself handleAdoptedProtocolsForInterface:class store:store];
	}];
}

- (void)handleExtensionsFromStore:(Store *)store {
	LogDebug(@"Handling extensions...");
	__weak LinkKnownObjectsTask *bself = self;
	[store.storeExtensions enumerateObjectsUsingBlock:^(CategoryInfo *extension, NSUInteger idx, BOOL *stop) {
		LogDebug(@"Handling %@...", extension);
		[bself handleExtendedClassesForCategory:extension store:store];
		[bself handleAdoptedProtocolsForInterface:extension store:store];
	}];
}

- (void)handleCategoriesFromStore:(Store *)store {
	LogDebug(@"Handling categories...");
	__weak LinkKnownObjectsTask *bself = self;
	[store.storeCategories enumerateObjectsUsingBlock:^(CategoryInfo *category, NSUInteger idx, BOOL *stop) {
		LogDebug(@"Handling %@...", category);
		[bself handleExtendedClassesForCategory:category store:store];
		[bself handleAdoptedProtocolsForInterface:category store:store];
	}];
}

- (void)handleProtocolsFromStore:(Store *)store {
	LogDebug(@"Handling protocols...");
	__weak LinkKnownObjectsTask *bself = self;
	[store.storeProtocols enumerateObjectsUsingBlock:^(ProtocolInfo *class, NSUInteger idx, BOOL *stop) {
		LogDebug(@"Handling %@...", class);
		[bself handleAdoptedProtocolsForInterface:class store:store];
	}];
}

#pragma mark - Common functionality

- (void)handleSuperClassesForClass:(ClassInfo *)class store:(Store *)store {
	if (class.nameOfSuperClass.length == 0) return;
	[store.storeClasses enumerateObjectsUsingBlock:^(ClassInfo *testedClass, NSUInteger idx, BOOL *stop) {
		if (testedClass == class) return;
		if (![testedClass.nameOfClass isEqualToString:class.nameOfSuperClass]) return;
		LogVerbose(@"Found link to super class %@.", testedClass);
		class.classSuperClass.linkToObject = testedClass;
		*stop = YES;
	}];
}

- (void)handleExtendedClassesForCategory:(CategoryInfo *)category store:(Store *)store {
	if (category.categoryClass.nameOfObject.length == 0) return;
	[store.storeClasses enumerateObjectsUsingBlock:^(ClassInfo *testedClass, NSUInteger idx, BOOL *stop) {
		if (![testedClass.nameOfClass isEqualToString:category.nameOfClass]) return;
		LogVerbose(@"Found link to extended class %@.", testedClass);
		category.categoryClass.linkToObject = testedClass;
		*stop = YES;
	}];
}

- (void)handleAdoptedProtocolsForInterface:(InterfaceInfoBase *)interface store:(Store *)store {
	LogDebug(@"Handling adopted protocols...");
	[interface.interfaceAdoptedProtocols enumerateObjectsUsingBlock:^(ObjectLinkInfo *link, NSUInteger idx, BOOL *stop) {
		[store.storeProtocols enumerateObjectsUsingBlock:^(ProtocolInfo *protocol, NSUInteger idx, BOOL *stop) {
			if (![protocol.nameOfProtocol isEqualToString:link.nameOfObject]) return;
			LogVerbose(@"Found link to %@.", protocol);
			link.linkToObject = protocol;
			*stop = YES;
		}];
	}];
}

@end
