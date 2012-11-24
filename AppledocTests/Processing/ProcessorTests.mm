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
			processor.splitCommentToSectionsTask should_not be_nil();
			processor.registerCommentComponentsTask should_not be_nil();
		});
	});
});

describe(@"running:", ^{
	describe(@"top level objects:", ^{
		it(@"should enumerate classes", ^{
			runWithProcessor(^(Processor *processor) {
				// setup
				id settings = mock([GBSettings class]);
				id classes = mock([NSArray class]);
				id store = mock([Store class]);
				[given([store storeClasses]) willReturn:classes];
				// execute
				[processor runWithSettings:settings store:store];
				// verify
				gbcatch([verify(classes) enumerateObjectsUsingBlock:(id)anything()]);
			});
		});

		it(@"should enumerate extensions", ^{
			runWithProcessor(^(Processor *processor) {
				// setup
				id settings = mock([GBSettings class]);
				id extensions = mock([NSArray class]);
				id store = mock([Store class]);
				[given([store storeExtensions]) willReturn:extensions];
				// execute
				[processor runWithSettings:settings store:store];
				// verify
				gbcatch([verify(extensions) enumerateObjectsUsingBlock:(id)anything()]);
			});
		});
		
		it(@"should enumerate categories", ^{
			runWithProcessor(^(Processor *processor) {
				// setup
				id settings = mock([GBSettings class]);
				id categories = mock([NSArray class]);
				id store = mock([Store class]);
				[given([store storeCategories]) willReturn:categories];
				// execute
				[processor runWithSettings:settings store:store];
				// verify
				gbcatch([verify(categories) enumerateObjectsUsingBlock:(id)anything()]);
			});
		});
		
		it(@"should enumerate protocols", ^{
			runWithProcessor(^(Processor *processor) {
				// setup
				id settings = mock([GBSettings class]);
				id protocols = mock([NSArray class]);
				id store = mock([Store class]);
				[given([store storeProtocols]) willReturn:protocols];
				// execute
				[processor runWithSettings:settings store:store];
				// verify
				gbcatch([verify(protocols) enumerateObjectsUsingBlock:(id)anything()]);
			});
		});
	});
	
	describe(@"members:", ^{
		__block InterfaceInfoBase *object;
		__block id classMethods;
		__block id interfaceMethods;
		__block id properties;
		
		beforeEach(^{
			classMethods = mock([NSArray class]);
			interfaceMethods = mock([NSArray class]);
			properties = mock([NSArray class]);
			object = [[[InterfaceInfoBase alloc] init] autorelease];
			object.interfaceClassMethods = classMethods;
			object.interfaceInstanceMethods = interfaceMethods;
			object.interfaceProperties = properties;
		});
		
		it(@"should enumerate class members", ^{
			runWithProcessor(^(Processor *processor) {
				// setup
				id settings = mock([GBSettings class]);
				id store = mock([Store class]);
				[given([store storeClasses]) willReturn:@[object]];
				// execute
				[processor runWithSettings:settings store:store];
				// verify
				gbcatch([verify(classMethods) enumerateObjectsUsingBlock:(id)anything()]);
				gbcatch([verify(interfaceMethods) enumerateObjectsUsingBlock:(id)anything()]);
				gbcatch([verify(properties) enumerateObjectsUsingBlock:(id)anything()]);
			});
		});
		
		it(@"should enumerate extension members", ^{
			runWithProcessor(^(Processor *processor) {
				// setup
				id settings = mock([GBSettings class]);
				id store = mock([Store class]);
				[given([store storeExtensions]) willReturn:@[object]];
				// execute
				[processor runWithSettings:settings store:store];
				// verify
				gbcatch([verify(classMethods) enumerateObjectsUsingBlock:(id)anything()]);
				gbcatch([verify(interfaceMethods) enumerateObjectsUsingBlock:(id)anything()]);
				gbcatch([verify(properties) enumerateObjectsUsingBlock:(id)anything()]);
			});
		});

		it(@"should enumerate category members", ^{
			runWithProcessor(^(Processor *processor) {
				// setup
				id settings = mock([GBSettings class]);
				id store = mock([Store class]);
				[given([store storeCategories]) willReturn:@[object]];
				// execute
				[processor runWithSettings:settings store:store];
				// verify
				gbcatch([verify(classMethods) enumerateObjectsUsingBlock:(id)anything()]);
				gbcatch([verify(interfaceMethods) enumerateObjectsUsingBlock:(id)anything()]);
				gbcatch([verify(properties) enumerateObjectsUsingBlock:(id)anything()]);
			});
		});
		
		it(@"should enumerate protocol members", ^{
			runWithProcessor(^(Processor *processor) {
				// setup
				id settings = mock([GBSettings class]);
				id store = mock([Store class]);
				[given([store storeProtocols]) willReturn:@[object]];
				// execute
				[processor runWithSettings:settings store:store];
				// verify
				gbcatch([verify(classMethods) enumerateObjectsUsingBlock:(id)anything()]);
				gbcatch([verify(interfaceMethods) enumerateObjectsUsingBlock:(id)anything()]);
				gbcatch([verify(properties) enumerateObjectsUsingBlock:(id)anything()]);
			});
		});
	});
});

describe(@"processing comments:", ^{
	__block id context;
	__block id object;
	__block id comment;
	__block id componentsTask;
	
	beforeEach(^{
		comment = [[CommentInfo alloc] init];
		context = mock([ObjectInfoBase class]);
		object = mock([ObjectInfoBase class]);
		componentsTask = mock([ProcessorTask class]);
	});
	
	it(@"should invoke split comment to sections task if comment given", ^{
		runWithProcessor(^(Processor *processor) {
			// setup
			[given([object comment]) willReturn:comment];
			processor.splitCommentToSectionsTask = componentsTask;
			// execute
			[processor processCommentForObject:object context:context];
			// verify
			gbcatch([verify(componentsTask) processCommentForObject:object context:context]);
		});
	});

	it(@"should invoke register comment components task if comment given", ^{
		runWithProcessor(^(Processor *processor) {
			// setup
			[given([object comment]) willReturn:comment];
			processor.registerCommentComponentsTask = componentsTask;
			// execute
			[processor processCommentForObject:object context:context];
			// verify
			gbcatch([verify(componentsTask) processCommentForObject:object context:context]);
		});
	});
	
	it(@"should ignore all required tasks if comment is not given", ^{
		runWithProcessor(^(Processor *processor) {
			// setup
			[given([object comment]) willReturn:nil];
			processor.splitCommentToSectionsTask = componentsTask;
			// execute
			[processor processCommentForObject:object context:context];
			// verify - we should fail because the method should not be invoked when comment is nil.
			gbfail([verify(componentsTask) processCommentForObject:object context:context]);
		});
	});
});

TEST_END