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
	if (!self.settings.searchForMissingComments) return GBResultOk;
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
		[bself fetchDocumentationFromAdoptedProtocolsOf:class missingBlock:^(id member) {
			// Note that we want to log undocumented members; users may disable warnings but if they turn verbosity to debug, they should still see what's going on.
			LogDebug(@"Documentation for %@ not found in adopted protocols, checking superclasses...", member);
			[bself fetchDocumentationFromSuperClassesOf:class forMember:member];
		}];
	}];
}

- (void)handleExtensionsFromStore:(Store *)store {
	LogDebug(@"Handling extensions...");
	[self fetchDocumentationFromAdoptedProtocolsForInterfaces:store.storeExtensions];
}

- (void)handleCategoriesFromStore:(Store *)store {
	LogDebug(@"Handling categories...");
	[self fetchDocumentationFromAdoptedProtocolsForInterfaces:store.storeCategories];
}

- (void)handleProtocolsFromStore:(Store *)store {
	LogDebug(@"Handling protocols...");
	[self fetchDocumentationFromAdoptedProtocolsForInterfaces:store.storeProtocols];
}

#pragma mark - Adopted protocols handling

- (void)fetchDocumentationFromAdoptedProtocolsForInterfaces:(NSArray *)interfaces {
	__weak FetchDocumentationTask *bself = self;
	[interfaces enumerateObjectsUsingBlock:^(InterfaceInfoBase *interface, NSUInteger idx, BOOL *stop) {
		LogDebug(@"Handling %@...", interface);
		[bself fetchDocumentationFromAdoptedProtocolsOf:interface missingBlock:^(id member) {
			// Similar to handleClassesFromStore: we want to always log undocumented members as debug messages...
			LogDebug(@"Member %@ is undocumented!", member);
			[bself reportUndocumentedMember:member];
		}];
	}];
}

- (void)fetchDocumentationFromAdoptedProtocolsOf:(InterfaceInfoBase *)interface missingBlock:(GBFetchBlock)handler {
	[self fetchDocumentationFromAdoptedProtocolsOf:interface members:@selector(interfaceClassMethods) missingBlock:handler];
	[self fetchDocumentationFromAdoptedProtocolsOf:interface members:@selector(interfaceInstanceMethods) missingBlock:handler];
	[self fetchDocumentationFromAdoptedProtocolsOf:interface members:@selector(interfaceProperties) missingBlock:handler];
}

- (void)fetchDocumentationFromAdoptedProtocolsOf:(InterfaceInfoBase *)interface members:(SEL)selector missingBlock:(GBFetchBlock)handler {
	__weak FetchDocumentationTask *bself = self;
	NSArray *interfaceMembers = [interface performSelector:selector];
	[interfaceMembers enumerateObjectsUsingBlock:^(ObjectInfoBase *member, NSUInteger idx, BOOL *stop) {
		if (member.comment) return;
		[interface.interfaceAdoptedProtocols enumerateObjectsUsingBlock:^(ObjectLinkInfo *adoptedProtocolLink, NSUInteger i, BOOL *istop) {
			ProtocolInfo *adoptedProtocol = adoptedProtocolLink.linkToObject;
			if (!adoptedProtocol) return;
			NSArray *adoptedMembers = [adoptedProtocol performSelector:selector];
			[adoptedMembers enumerateObjectsUsingBlock:^(ObjectInfoBase *adoptedMember, NSUInteger j, BOOL *jstop) {
				if (!adoptedMember.comment) return;
				if (![adoptedMember.uniqueObjectID isEqualToString:member.uniqueObjectID]) return;
				[bself copyDocumentationFrom:adoptedMember to:member];
				*jstop = YES;
				*istop = YES;
			}];
		}];
		if (!member.comment) handler(member);
	}];
}

#pragma mark - Super classes handling

- (void)fetchDocumentationFromSuperClassesOf:(ClassInfo *)class forMember:(id)member {
	ClassInfo *superClass = class.classSuperClass.linkToObject;
	while (superClass) {
		LogDebug(@"Checking super class %@...", superClass);
		if ([self fetchDocumentationFromSuperClassMembers:superClass.interfaceClassMethods forMember:member]) break;
		if ([self fetchDocumentationFromSuperClassMembers:superClass.interfaceInstanceMethods forMember:member]) break;
		if ([self fetchDocumentationFromSuperClassMembers:superClass.interfaceProperties forMember:member]) break;
		superClass = superClass.classSuperClass.linkToObject;
	}
	if (![member comment]) {
		LogDebug(@"Member %@ is undocumented!", [member descriptionWithParent]);
		[self reportUndocumentedMember:member];
	}
}

- (BOOL)fetchDocumentationFromSuperClassMembers:(NSArray *)superMembers forMember:(ObjectInfoBase *)member {
	__weak FetchDocumentationTask *bself = self;
	[superMembers enumerateObjectsUsingBlock:^(ObjectInfoBase *superMember, NSUInteger idx, BOOL *stop) {
		if (!superMember.comment) return;
		if (![superMember.uniqueObjectID isEqualToString:member.uniqueObjectID]) return;
		[bself copyDocumentationFrom:superMember to:member];
	}];
}

#pragma mark - Copying documentation

- (void)copyDocumentationFrom:(MemberInfoBase *)source to:(MemberInfoBase *)dest {
	LogVerbose(@"Fetching documentation for %@ from %@.", [dest descriptionWithParent], [source descriptionWithParent]);
	dest.comment = source.comment;
}

#pragma mark - Undocumented objects handling

- (void)reportUndocumentedMember:(id)object {
	LogWarn(@"%@ is undocumented!", [object descriptionWithParent]);
}

@end
