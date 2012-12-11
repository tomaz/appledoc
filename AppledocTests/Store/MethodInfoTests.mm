//
//  MethodInfoTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/17/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "TestCaseBase.hh"

static void runWithMethodInfo(void(^handler)(MethodInfo *info)) {
	MethodInfo *info = [[MethodInfo alloc] init];
	handler(info);
	[info release];
}

static void runWithMethodInfoWithRegistrar(void(^handler)(MethodInfo *info, Store *store)) {
	runWithMethodInfo(^(MethodInfo *info) {
		Store *store = [[Store alloc] init];
		info.objectRegistrar = store;
		handler(info, store);
		[store release];
	});
}

#pragma mark - 

TEST_BEGIN(MethodInfoTests)

describe(@"lazy accessors:", ^{
	it(@"should initialize objects", ^{
		runWithMethodInfo(^(MethodInfo *info) {
			// execute & verify
			info.methodResult should be_instance_of([TypeInfo class]);
			info.methodDescriptors should_not be_nil();
			info.methodArguments should_not be_nil();
		});
	});
});

describe(@"selector, unique ID & cross reference template:", ^{
	it(@"should handle class method", ^{
		runWithMethodInfo(^(MethodInfo *info) {
			// setup
			MethodArgumentInfo *argument = [[MethodArgumentInfo alloc] init];
			argument.argumentSelector = @"method";
			[info.methodArguments addObject:argument];
			info.methodType = GBStoreTypes.classMethod;
			// execute & verify
			info.uniqueObjectID should equal(@"+method");
			info.objectCrossRefPathTemplate should equal(@"#+method");
		});
	});
	
	it(@"should handle single argument", ^{
		runWithMethodInfo(^(MethodInfo *info) {
			// setup
			MethodArgumentInfo *argument = [[MethodArgumentInfo alloc] init];
			argument.argumentSelector = @"method";
			[info.methodArguments addObject:argument];
			// execute & verify
			info.uniqueObjectID should equal(@"-method");
			info.objectCrossRefPathTemplate should equal(@"#-method");
		});
	});

	it(@"should handle single argument with variable", ^{
		runWithMethodInfo(^(MethodInfo *info) {
			// setup
			MethodArgumentInfo *argument = [[MethodArgumentInfo alloc] init];
			argument.argumentSelector = @"method";
			argument.argumentVariable = @"var";
			[info.methodArguments addObject:argument];
			// execute & verify
			info.uniqueObjectID should equal(@"-method:");
			info.objectCrossRefPathTemplate should equal(@"#-method:");
		});
	});
	
	it(@"should handle multiple arguments", ^{
		runWithMethodInfo(^(MethodInfo *info) {
			// setup
			MethodArgumentInfo *argument1 = [[MethodArgumentInfo alloc] init];
			argument1.argumentSelector = @"method";
			argument1.argumentVariable = @"var";
			[info.methodArguments addObject:argument1];
			MethodArgumentInfo *argument2 = [[MethodArgumentInfo alloc] init];
			argument2.argumentSelector = @"withArg";
			argument2.argumentVariable = @"var";
			[info.methodArguments addObject:argument2];
			// execute & verify
			info.uniqueObjectID should equal(@"-method:withArg:");
			info.objectCrossRefPathTemplate should equal(@"#-method:withArg:");
		});
	});
});

describe(@"class or interface method helpers:", ^{
	it(@"should work for class method", ^{
		runWithMethodInfo(^(MethodInfo *info) {			
			// setup
			info.methodType = GBStoreTypes.classMethod;
			// execute & verify
			info.isClassMethod should equal(YES);
			info.isInstanceMethod should equal(NO);
		});
	});

	it(@"should work for instance method", ^{
		runWithMethodInfo(^(MethodInfo *info) {			
			// setup
			info.methodType = GBStoreTypes.instanceMethod;
			// execute & verify
			info.isClassMethod should equal(NO);
			info.isInstanceMethod should equal(YES);
		});
	});
});

describe(@"method results registration:", ^{
	it(@"should change current registration object to results", ^{
		runWithMethodInfo(^(MethodInfo *info) {
			// setup
			id mock = mock([Store class]);
			info.objectRegistrar = mock;
			// execute
			[info beginMethodResults];
			// verify
			gbcatch([verify(mock) pushRegistrationObject:instanceOf([TypeInfo class])]);
		});
	});
});

describe(@"method argument registration:", ^{
	it(@"should create new method argument", ^{
		runWithMethodInfo(^(MethodInfo *info) {
			// setup
			info.objectRegistrar = mock([Store class]);
			// execute
			[info beginMethodArgument];
			// verify
			info.methodArguments.count should equal(1);
			info.methodArguments.lastObject should be_instance_of([MethodArgumentInfo class]);
			[info.methodArguments.lastObject objectRegistrar] should equal(info.objectRegistrar);
		});
	});

	it(@"should push argument to registration stack", ^{
		runWithMethodInfo(^(MethodInfo *info) {
			// setup
			id mock = mock([Store class]);
			info.objectRegistrar = mock;
			// execute
			[info beginMethodArgument];
			// verify
			gbcatch([verify(mock) pushRegistrationObject:instanceOf([MethodArgumentInfo class])]);
		});
	});
});

describe(@"method descriptors registration:", ^{
	it(@"should change current registration object to descriptors info", ^{
		runWithMethodInfo(^(MethodInfo *info) {
			// setup
			id mock = mock([Store class]);
			info.objectRegistrar = mock;
			// execute
			[info beginMethodDescriptors];
			// verify
			gbcatch([verify(mock) pushRegistrationObject:instanceOf([DescriptorsInfo class])]);
		});
	});
});

describe(@"object cancellation:", ^{
	it(@"should remove method argument if current registration object", ^{
		runWithMethodInfoWithRegistrar(^(MethodInfo *info, Store *store) {
			// setup
			[info beginMethodArgument];
			// execute
			[info cancelCurrentObject];
			// verify
			info.methodArguments.count should equal(0);
		});
	});

	it(@"should not remove method argument if current registration object is different", ^{
		runWithMethodInfoWithRegistrar(^(MethodInfo *info, Store *store) {
			// setup
			[info beginMethodArgument];
			[info beginMethodResults];
			// execute
			[info cancelCurrentObject];
			// verify
			info.methodArguments.count should equal(1);
		});
	});
});

TEST_END
