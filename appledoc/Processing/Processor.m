//
//  Processor.m
//  appledoc
//
//  Created by Tomaz Kragelj on 8/11/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "Store.h"
#import "ProcessCommentComponentsTask.h"
#import "Processor.h"

#define GB_PROCESS(code) { NSInteger intermediateResult = code; if (intermediateResult > result) result = intermediateResult; }

#pragma mark -

@implementation Processor

#pragma mark - Task invocation

- (NSInteger)runTask {
	LogNormal(@"Processing started...");
	__weak Processor *blockSelf = self;
	__block GBResult result = GBResultOk;

	LogInfo(@"Processing classes...");
	[self.store.storeClasses enumerateObjectsUsingBlock:^(InterfaceInfoBase *info, NSUInteger idx, BOOL *stop) {
		GB_PROCESS([blockSelf processInterface:info]);
	}];
	
	LogInfo(@"Processing extensions...");
	[self.store.storeExtensions enumerateObjectsUsingBlock:^(InterfaceInfoBase *info, NSUInteger idx, BOOL *stop) {
		GB_PROCESS([blockSelf processInterface:info]);
	}];
	
	LogInfo(@"Processing categories...");
	[self.store.storeCategories enumerateObjectsUsingBlock:^(InterfaceInfoBase *info, NSUInteger idx, BOOL *stop) {
		GB_PROCESS([blockSelf processInterface:info]);
	}];
	
	LogInfo(@"Processing protocols...");
	[self.store.storeProtocols enumerateObjectsUsingBlock:^(InterfaceInfoBase *info, NSUInteger idx, BOOL *stop) {
		GB_PROCESS([blockSelf processInterface:info]);
	}];
	
	LogInfo(@"Processing finished.");
	return result;
}

#pragma mark - Processor helpers

- (NSInteger)processInterface:(InterfaceInfoBase *)interface {
	LogVerbose(@"Processing %@...", interface);
	NSInteger result = GBResultOk;
	[self processCommentForObject:interface context:interface];
	GB_PROCESS([self processMembers:interface.interfaceClassMethods forObject:interface]);
	GB_PROCESS([self processMembers:interface.interfaceInstanceMethods forObject:interface]);
	GB_PROCESS([self processMembers:interface.interfaceProperties forObject:interface]);
	return result;
}

- (NSInteger *)processMembers:(NSArray *)members forObject:(InterfaceInfoBase *)object {
	__weak Processor *blockSelf = self;
	__block NSInteger result = GBResultOk;
	[members enumerateObjectsUsingBlock:^(ObjectInfoBase *member, NSUInteger idx, BOOL *stop) {
		LogDebug(@"Processing %@...", member);
		[blockSelf processCommentForObject:member context:object];
	}];
	return result;
}

- (NSInteger)processCommentForObject:(ObjectInfoBase *)object context:(ObjectInfoBase *)context {
	if (!object.comment) return GBResultOk;
	LogProDebug(@"Processing comment for %@", object);
	NSInteger result = GBResultOk;
	GB_PROCESS([self.processCommentComponentsTask processCommentForObject:object context:context])
	return result;
}

#pragma mark - Lazy loading properties

- (ProcessorTask *)processCommentComponentsTask {
	if (_processCommentComponentsTask) return _processCommentComponentsTask;
	LogIntDebug(@"Initializing comment components processor task due to first acces...");
	_processCommentComponentsTask = [[ProcessCommentComponentsTask alloc] init];
	return _processCommentComponentsTask;
}

@end
