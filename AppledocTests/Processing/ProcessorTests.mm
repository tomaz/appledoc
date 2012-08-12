//
//  ProcessorTests.m
//  appledoc
//
//  Created by Tomaz Kragelj on 8/11/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "Processor.h"
#import "TestCaseBase.hh"

static void runWithProcessor(void(^handler)(Processor *processor)) {
	Processor *processor = [[Processor alloc] init];
	handler(processor);
	[processor release];
}

#pragma mark - 

@interface Processor (UnitTestingPrivateAPI)
- (NSInteger)processCommentForObject:(ObjectInfoBase *)object context:(ObjectInfoBase *)parent;
@end

#pragma mark -

TEST_BEGIN(ProcessorTests)

describe(@"lazy accessors:", ^{
	it(@"should initialize objects", ^{
		runWithProcessor(^(Processor *processor) {
			// execute & verify
			processor.processCommentComponentsTask should_not be_nil();
		});
	});
});

describe(@"running:", ^{
	describe(@"top level objects:", ^{
		it(@"should enumerate classes", ^{
			runWithProcessor(^(Processor *processor) {
				// setup
				id settings = [OCMockObject niceMockForClass:[GBSettings class]];
				id classes = [OCMockObject mockForClass:[NSArray class]];
				[[classes expect] enumerateObjectsUsingBlock:OCMOCK_ANY];
				id store = [OCMockObject niceMockForClass:[Store class]];
				[[[store expect] andReturn:classes] storeClasses];
				// execute
				[processor runWithSettings:settings store:store];
				// verify
				^{ [store verify]; } should_not raise_exception();
				^{ [classes verify]; } should_not raise_exception();
			});
		});

		it(@"should enumerate extensions", ^{
			runWithProcessor(^(Processor *processor) {
				// setup
				id settings = [OCMockObject niceMockForClass:[GBSettings class]];
				id extensions = [OCMockObject mockForClass:[NSArray class]];
				[[extensions expect] enumerateObjectsUsingBlock:OCMOCK_ANY];
				id store = [OCMockObject niceMockForClass:[Store class]];
				[[[store expect] andReturn:extensions] storeExtensions];
				// execute
				[processor runWithSettings:settings store:store];
				// verify
				^{ [store verify]; } should_not raise_exception();
				^{ [extensions verify]; } should_not raise_exception();
			});
		});
		
		it(@"should enumerate categories", ^{
			runWithProcessor(^(Processor *processor) {
				// setup
				id settings = [OCMockObject niceMockForClass:[GBSettings class]];
				id categories = [OCMockObject mockForClass:[NSArray class]];
				[[categories expect] enumerateObjectsUsingBlock:OCMOCK_ANY];
				id store = [OCMockObject niceMockForClass:[Store class]];
				[[[store expect] andReturn:categories] storeCategories];
				// execute
				[processor runWithSettings:settings store:store];
				// verify
				^{ [store verify]; } should_not raise_exception();
				^{ [categories verify]; } should_not raise_exception();
			});
		});
		
		it(@"should enumerate protocols", ^{
			runWithProcessor(^(Processor *processor) {
				// setup
				id settings = [OCMockObject niceMockForClass:[GBSettings class]];
				id protocols = [OCMockObject mockForClass:[NSArray class]];
				[[protocols expect] enumerateObjectsUsingBlock:OCMOCK_ANY];
				id store = [OCMockObject niceMockForClass:[Store class]];
				[[[store expect] andReturn:protocols] storeProtocols];
				// execute
				[processor runWithSettings:settings store:store];
				// verify
				^{ [store verify]; } should_not raise_exception();
				^{ [protocols verify]; } should_not raise_exception();
			});
		});
	});
	
	describe(@"members:", ^{
		__block InterfaceInfoBase *object;
		__block id classMethods;
		__block id interfaceMethods;
		__block id properties;
		
		beforeEach(^{
			classMethods = [OCMockObject mockForClass:[NSArray class]];
			[[classMethods expect] enumerateObjectsUsingBlock:OCMOCK_ANY];
			interfaceMethods = [OCMockObject mockForClass:[NSArray class]];
			[[interfaceMethods expect] enumerateObjectsUsingBlock:OCMOCK_ANY];
			properties = [OCMockObject mockForClass:[NSArray class]];
			[[properties expect] enumerateObjectsUsingBlock:OCMOCK_ANY];
			object = [[[InterfaceInfoBase alloc] init] autorelease];
			object.interfaceClassMethods = classMethods;
			object.interfaceInstanceMethods = interfaceMethods;
			object.interfaceProperties = properties;
		});
		
		it(@"should enumerate class members", ^{
			runWithProcessor(^(Processor *processor) {
				// setup
				id settings = [OCMockObject niceMockForClass:[GBSettings class]];
				id store = [OCMockObject niceMockForClass:[Store class]];
				[[[store expect] andReturn:@[object]] storeClasses];
				// execute
				[processor runWithSettings:settings store:store];
				// verify
				^{ [classMethods verify]; } should_not raise_exception();
				^{ [interfaceMethods verify]; } should_not raise_exception();
				^{ [properties verify]; } should_not raise_exception();
			});
		});
		
		it(@"should enumerate extension members", ^{
			runWithProcessor(^(Processor *processor) {
				// setup
				id settings = [OCMockObject niceMockForClass:[GBSettings class]];
				id store = [OCMockObject niceMockForClass:[Store class]];
				[[[store expect] andReturn:@[object]] storeExtensions];
				// execute
				[processor runWithSettings:settings store:store];
				// verify
				^{ [classMethods verify]; } should_not raise_exception();
				^{ [interfaceMethods verify]; } should_not raise_exception();
				^{ [properties verify]; } should_not raise_exception();
			});
		});

		it(@"should enumerate category members", ^{
			runWithProcessor(^(Processor *processor) {
				// setup
				id settings = [OCMockObject niceMockForClass:[GBSettings class]];
				id store = [OCMockObject niceMockForClass:[Store class]];
				[[[store expect] andReturn:@[object]] storeCategories];
				// execute
				[processor runWithSettings:settings store:store];
				// verify
				^{ [classMethods verify]; } should_not raise_exception();
				^{ [interfaceMethods verify]; } should_not raise_exception();
				^{ [properties verify]; } should_not raise_exception();
			});
		});
		
		it(@"should enumerate protocol members", ^{
			runWithProcessor(^(Processor *processor) {
				// setup
				id settings = [OCMockObject niceMockForClass:[GBSettings class]];
				id store = [OCMockObject niceMockForClass:[Store class]];
				[[[store expect] andReturn:@[object]] storeProtocols];
				// execute
				[processor runWithSettings:settings store:store];
				// verify
				^{ [classMethods verify]; } should_not raise_exception();
				^{ [interfaceMethods verify]; } should_not raise_exception();
				^{ [properties verify]; } should_not raise_exception();
			});
		});
	});
});

describe(@"processing comments:", ^{
	__block id context;
	__block id object;
	__block id componentsTask;
	
	beforeEach(^{
		context = [OCMockObject mockForClass:[ObjectInfoBase class]];
		object = [OCMockObject mockForClass:[ObjectInfoBase class]];
		componentsTask = [OCMockObject mockForClass:[ProcessorTask class]];
	});
	
	it(@"should invoke all required tasks if comment is given", ^{
		runWithProcessor(^(Processor *processor) {
			// setup
			[[[object stub] andReturn:@""] comment];
			[[componentsTask expect] processCommentForObject:object context:context];
			processor.processCommentComponentsTask = componentsTask;
			// execute
			[processor processCommentForObject:object context:context];
			// verify
			^{ [componentsTask verify]; } should_not raise_exception();
		});
	});

	it(@"should ignore all required tasks if comment is not given", ^{
		runWithProcessor(^(Processor *processor) {
			// setup - no need to specify expectations as strict mock will raise exception if unexpected message is received
			[[[object stub] andReturn:nil] comment];
			processor.processCommentComponentsTask = componentsTask;
			// execute
			[processor processCommentForObject:object context:context];
			// verify
			^{ [componentsTask verify]; } should_not raise_exception();
		});
	});
});

TEST_END