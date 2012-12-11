//
//  FetchDocumentationTask.m
//  appledoc
//
//  Created by Tomaz Kragelj on 10.12.12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "Store.h"
#import "FetchDocumentationTask.h"

typedef void(^GBFetchBlock)(id member);

@implementation FetchDocumentationTask

- (GBResult)runTask {
	LogDebug(@"Fetching documentation from related objects...");
	[self handleClassesFromStore:self.store];
	[self handleExtensionsFromStore:self.store];
	[self handleCategoriesFromStore:self.store];
	[self handleProtocolsFromStore:self.store];
	return GBResultOk;
}

#pragma mark - Top level objects handling

- (void)handleClassesFromStore:(Store *)store {
	LogDebug(@"Handling classes...");
	__weak FetchDocumentationTask *bself = self;
	[store.storeClasses enumerateObjectsUsingBlock:^(ClassInfo *class, NSUInteger idx, BOOL *stop) {
		LogDebug(@"Handling %@...", class);
		[bself fetchDocumentationForMembersOf:class block:^(id member) {
			
		}];
	}];
}

- (void)handleExtensionsFromStore:(Store *)store {
	LogDebug(@"Handling extensions...");
	__weak FetchDocumentationTask *bself = self;
	[store.storeExtensions enumerateObjectsUsingBlock:^(CategoryInfo *extension, NSUInteger idx, BOOL *stop) {
		LogDebug(@"Handling %@...", extension);
		[bself fetchDocumentationForMembersOf:extension block:^(id member) { }];
	}];
}

- (void)handleCategoriesFromStore:(Store *)store {
	LogDebug(@"Handling categories...");
	__weak FetchDocumentationTask *bself = self;
	[store.storeCategories enumerateObjectsUsingBlock:^(CategoryInfo *category, NSUInteger idx, BOOL *stop) {
		LogDebug(@"Handling %@...", category);
		[bself fetchDocumentationForMembersOf:category block:^(id member) { }];
	}];
}

- (void)handleProtocolsFromStore:(Store *)store {
	LogDebug(@"Handling protocols...");
	__weak FetchDocumentationTask *bself = self;
	[store.storeProtocols enumerateObjectsUsingBlock:^(ProtocolInfo *protocol, NSUInteger idx, BOOL *stop) {
		LogDebug(@"Handling %@...", protocol);
		[bself fetchDocumentationForMembersOf:protocol block:^(id member) { }];
	}];
}

#pragma mark - Members handling

- (void)fetchDocumentationForMembersOf:(InterfaceInfoBase *)interface block:(GBFetchBlock)handler {
	if (interface.interfaceAdoptedProtocols.count == 0) return;
	[self fetchDocumentationForMembersOf:interface members:@selector(interfaceClassMethods) block:handler];
	[self fetchDocumentationForMembersOf:interface members:@selector(interfaceInstanceMethods) block:handler];
	[self fetchDocumentationForMembersOf:interface members:@selector(interfaceProperties) block:handler];
}

- (void)fetchDocumentationForMembersOf:(InterfaceInfoBase *)interface members:(SEL)selector block:(GBFetchBlock)handler {
	NSArray *interfaceMembers = [interface performSelector:selector];
	[interfaceMembers enumerateObjectsUsingBlock:^(ObjectInfoBase *member, NSUInteger idx, BOOL *stop) {
		if (member.comment) return;
		[interface.interfaceAdoptedProtocols enumerateObjectsUsingBlock:^(ObjectLinkInfo *adoptedProtocolLink, NSUInteger i, BOOL *istop) {
			ProtocolInfo *adoptedProtocol = adoptedProtocolLink.linkToObject;
			if (!adoptedProtocol) return;
			NSArray *adoptedMembers = [adoptedProtocol performSelector:selector];
			[adoptedMembers enumerateObjectsUsingBlock:^(ObjectInfoBase *adoptedMember, NSUInteger j, BOOL *jstop) {
				if (![adoptedMember.uniqueObjectID isEqualToString:member.uniqueObjectID]) return;
				if (!adoptedMember.comment) return;
				LogVerbose(@"Fetching documentation for %@ from %@.", [(id)member descriptionWithInterface:interface], [(id)adoptedMember descriptionWithInterface:adoptedProtocol]);
				member.comment = adoptedMember.comment;
				*jstop = YES;
				*istop = YES;
			}];
		}];
		if (!member.comment) handler(member);
	}];
}

@end
