//
//  LinkKnownObjectsTaskTests.m
//  appledoc
//
//  Created by Tomaz Kragelj on 7/12/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "LinkKnownObjectsTask.h"
#import "TestCaseBase.hh"

#define GBSections [comment sourceSections]

#pragma mark -

static void runWithTask(void(^handler)(LinkKnownObjectsTask *task, id store)) {
	LinkKnownObjectsTask *task = [[LinkKnownObjectsTask alloc] init];
	task.store = mock([Store class]);
	handler(task, task.store);
	[task release];
}

static id createInterface(void(^handler)(InterfaceInfoBase *interface)) {
	InterfaceInfoBase *result = [[InterfaceInfoBase alloc] init];
	handler(result);
	return result;
}

static id createProtocol(NSString *name) {
	id result = mock([ProtocolInfo class]);
	[given([result nameOfProtocol]) willReturn:name];
	return result;
}

static void adopt(InterfaceInfoBase *interface, NSString *first, ...) {
	va_list args;
	va_start(args, first);
	for (NSString *arg=first; arg!=nil; arg=va_arg(args, NSString *)) {
		ObjectLinkInfo *link = [[ObjectLinkInfo alloc] init];
		link.nameOfObject = arg;
		[interface.interfaceAdoptedProtocols addObject:link];
	}
	va_end(args);
}

#pragma mark -

TEST_BEGIN(LinkKnownObjectsTaskTests)

describe(@"adopted protocols:", ^{
	sharedExamplesFor(@"examples", ^(NSDictionary *info) {
		it(@"should link classes to known protocols", ^{
			runWithTask(^(LinkKnownObjectsTask *task, id store) {
				// setup
				InterfaceInfoBase *class1 = createInterface(^(InterfaceInfoBase *interface) {
					adopt(interface, @"MyProtocol1", @"MyProtocol2", @"UnknownProtocol", nil);
				});
				id protocol1 = createProtocol(@"MyProtocol1");
				id protocol2 = createProtocol(@"MyProtocol2");
				[given([store storeProtocols]) willReturn:@[ protocol1, protocol2 ]];
				[given([store storeClasses]) willReturn:@[ class1 ]];
				// execute
				[task runTask];
				// verify
				[class1.interfaceAdoptedProtocols[0] linkToObject] should equal(protocol1);
				[class1.interfaceAdoptedProtocols[1] linkToObject] should equal(protocol2);
				[class1.interfaceAdoptedProtocols[2] linkToObject] should be_nil();
			});
		});
	});
	
	it(@"should link extensions to known protocols", ^{
		runWithTask(^(LinkKnownObjectsTask *task, id store) {
			// setup
			InterfaceInfoBase *extension1 = createInterface(^(InterfaceInfoBase *interface) {
				adopt(interface, @"MyProtocol1", @"MyProtocol2", @"UnknownProtocol", nil);
			});
			id protocol1 = createProtocol(@"MyProtocol1");
			id protocol2 = createProtocol(@"MyProtocol2");
			[given([store storeProtocols]) willReturn:@[ protocol1, protocol2 ]];
			[given([store storeExtensions]) willReturn:@[ extension1 ]];
			// execute
			[task runTask];
			// verify
			[extension1.interfaceAdoptedProtocols[0] linkToObject] should equal(protocol1);
			[extension1.interfaceAdoptedProtocols[1] linkToObject] should equal(protocol2);
			[extension1.interfaceAdoptedProtocols[2] linkToObject] should be_nil();
		});
	});

	it(@"should link categories to known protocols", ^{
		runWithTask(^(LinkKnownObjectsTask *task, id store) {
			// setup
			InterfaceInfoBase *category1 = createInterface(^(InterfaceInfoBase *interface) {
				adopt(interface, @"MyProtocol1", @"MyProtocol2", @"UnknownProtocol", nil);
			});
			id protocol1 = createProtocol(@"MyProtocol1");
			id protocol2 = createProtocol(@"MyProtocol2");
			[given([store storeProtocols]) willReturn:@[ protocol1, protocol2 ]];
			[given([store storeCategories]) willReturn:@[ category1 ]];
			// execute
			[task runTask];
			// verify
			[category1.interfaceAdoptedProtocols[0] linkToObject] should equal(protocol1);
			[category1.interfaceAdoptedProtocols[1] linkToObject] should equal(protocol2);
			[category1.interfaceAdoptedProtocols[2] linkToObject] should be_nil();
		});
	});

	it(@"should link protocols to known protocols", ^{
		runWithTask(^(LinkKnownObjectsTask *task, id store) {
			// setup
			InterfaceInfoBase *protocol1 = createInterface(^(InterfaceInfoBase *interface) {
				adopt(interface, @"MyProtocol1", @"MyProtocol2", @"UnknownProtocol", nil);
			});
			id protocol2 = createProtocol(@"MyProtocol1");
			id protocol3 = createProtocol(@"MyProtocol2");
			[given([store storeProtocols]) willReturn:@[ protocol2, protocol3 ]];
			[given([store storeClasses]) willReturn:@[ protocol1 ]];
			// execute
			[task runTask];
			// verify
			[protocol1.interfaceAdoptedProtocols[0] linkToObject] should equal(protocol2);
			[protocol1.interfaceAdoptedProtocols[1] linkToObject] should equal(protocol3);
			[protocol1.interfaceAdoptedProtocols[2] linkToObject] should be_nil();
		});
	});
});

TEST_END