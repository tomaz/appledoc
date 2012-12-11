//
//  FetchDocumentationTaskTests.m
//  appledoc
//
//  Created by Tomaz Kragelj on 7/12/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "StoreMocks.h"
#import "FetchDocumentationTask.h"
#import "TestCaseBase.hh"

#define GBSections [comment sourceSections]

#pragma mark -

static void runWithTask(void(^handler)(FetchDocumentationTask *task, id store)) {
	FetchDocumentationTask *task = [[FetchDocumentationTask alloc] init];
	task.store = mock([Store class]);
	handler(task, task.store);
	[task release];
}

#pragma mark -

TEST_BEGIN(FetchDocumentationTaskTests)

describe(@"adopted protocols:", ^{
	sharedExamplesFor(@"examples", ^(NSDictionary *info) {
		__block id protocol;
		__block id object;
		__block id realStore;
		
		beforeEach(^{
			// get objects from info dictionary
			realStore = info[@"store"];
			object = info[@"object"];
			// setup protocol and assign it to store; note that we need to append our protocol to existing ones!
			protocol = [StoreMocks mockProtocol:@"Protocol"];
			NSMutableArray *actualProtocols = [NSMutableArray arrayWithArray:[realStore storeProtocols]];
			[actualProtocols addObject:protocol];
			[given([realStore storeProtocols]) willReturn:actualProtocols];
			// adopt the protocol
			[given([object interfaceAdoptedProtocols]) willReturn:@[ [StoreMocks link:protocol] ]];
		});
		
		it(@"should fetch for class methods", ^{
			runWithTask(^(FetchDocumentationTask *task, id store) {
				// setup class methods in protocol
				ObjectInfoBase *protocolClassMethod = [StoreMocks mockCommentedMethod:@"+method"];
				[given([protocol interfaceClassMethods]) willReturn:@[ protocolClassMethod ]];
				// setup class methods in object
				MethodInfo *objectClassMethod = [StoreMocks createMethod:@"+method"];
				[given([object interfaceClassMethods]) willReturn:@[ objectClassMethod ]];
				// setup task
				task.store = realStore;
				// execute
				[task runTask];
				// verify
				objectClassMethod.comment should equal(protocolClassMethod.comment);
			});
		});
		
		it(@"should fetch for instance methods", ^{
			runWithTask(^(FetchDocumentationTask *task, id store) {
				// setup instance methods in protocol
				ObjectInfoBase *protocolInstanceMethod = [StoreMocks mockCommentedMethod:@"+method"];
				[given([protocol interfaceInstanceMethods]) willReturn:@[ protocolInstanceMethod ]];
				// setup instance methods in object
				MethodInfo *objectInstanceMethod = [StoreMocks createMethod:@"+method"];
				[given([object interfaceInstanceMethods]) willReturn:@[ objectInstanceMethod ]];
				// setup task
				task.store = realStore;
				// execute
				[task runTask];
				// verify
				objectInstanceMethod.comment should equal(protocolInstanceMethod.comment);
			});
		});

		it(@"should fetch for properties", ^{
			runWithTask(^(FetchDocumentationTask *task, id store) {
				// setup properties in protocol
				ObjectInfoBase *protocolProperty = [StoreMocks mockCommentedProperty:@"property"];
				[given([protocol interfaceProperties]) willReturn:@[ protocolProperty ]];
				// setup properties in object
				PropertyInfo *objectProperty = [StoreMocks createProperty:@"property"];
				[given([object interfaceProperties]) willReturn:@[ objectProperty ]];
				// setup task
				task.store = realStore;
				// execute
				[task runTask];
				// verify
				objectProperty.comment should equal(protocolProperty.comment);
			});
		});
	});
	
	describe(@"classes:", ^{
		beforeEach(^{
			id store = mock([Store class]);
			id object = mock([ClassInfo class]);
			[given([store storeClasses]) willReturn:@[ object ]];
			[[SpecHelper specHelper] sharedExampleContext][@"store"] = store;
			[[SpecHelper specHelper] sharedExampleContext][@"object"] = object;
		});
		itShouldBehaveLike(@"examples");
	});
	
	describe(@"extensions:", ^{
		beforeEach(^{
			id store = mock([Store class]);
			id object = mock([CategoryInfo class]);
			[given([store storeExtensions]) willReturn:@[ object ]];
			[[SpecHelper specHelper] sharedExampleContext][@"store"] = store;
			[[SpecHelper specHelper] sharedExampleContext][@"object"] = object;
		});
		itShouldBehaveLike(@"examples");
	});
	
	describe(@"categories:", ^{
		beforeEach(^{
			id store = mock([Store class]);
			id object = mock([CategoryInfo class]);
			[given([store storeCategories]) willReturn:@[ object ]];
			[[SpecHelper specHelper] sharedExampleContext][@"store"] = store;
			[[SpecHelper specHelper] sharedExampleContext][@"object"] = object;
		});
		itShouldBehaveLike(@"examples");
	});
	
	describe(@"protocols:", ^{
		beforeEach(^{
			id store = mock([Store class]);
			id object = mock([ProtocolInfo class]);
			[given([store storeProtocols]) willReturn:@[ object ]];
			[[SpecHelper specHelper] sharedExampleContext][@"store"] = store;
			[[SpecHelper specHelper] sharedExampleContext][@"object"] = object;
		});
		itShouldBehaveLike(@"examples");
	});
});

TEST_END