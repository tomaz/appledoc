//
//  InterfaceInfoBaseTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/13/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "TestCaseBase.hh"

static void runWithInterfaceInfoBase(void(^handler)(InterfaceInfoBase *info)) {
	InterfaceInfoBase *info = [[InterfaceInfoBase alloc] initWithRegistrar:nil];
	handler(info);
	[info release];
}

static void runWithInterfaceInfoBaseWithRegistrar(void(^handler)(InterfaceInfoBase *info, Store *store)) {
	runWithInterfaceInfoBase(^(InterfaceInfoBase *info) {
		Store *store = [[Store alloc] init];
		info.objectRegistrar = store;
		handler(info, store);
		[store release];
	});
}

#pragma mark - 

TEST_BEGIN(InterfaceInfoBaseTests)

describe(@"lazy accessors", ^{
	it(@"should initialize objects", ^{
		runWithInterfaceInfoBase(^(InterfaceInfoBase *info) {
			// execute & verify
			info.interfaceAdoptedProtocols should_not be_nil();
			info.interfaceMethodGroups should_not be_nil();
			info.interfaceProperties should_not be_nil();
			info.interfaceInstanceMethods should_not be_nil();
			info.interfaceClassMethods should_not be_nil();
		});
	});
});

describe(@"adopted protocols registration", ^{
	it(@"should add all protocols to array", ^{
		runWithInterfaceInfoBase(^(InterfaceInfoBase *info) {
			// execute
			[info appendAdoptedProtocolWithName:@"name1"];
			[info appendAdoptedProtocolWithName:@"name2"];
			// verify
			info.interfaceAdoptedProtocols.count should equal(2);
			[[info.interfaceAdoptedProtocols objectAtIndex:0] nameOfObject] should equal(@"name1");
			[[info.interfaceAdoptedProtocols objectAtIndex:1] nameOfObject] should equal(@"name2");
		});
	});
	
	it(@"should ignore existing names", ^{
		runWithInterfaceInfoBase(^(InterfaceInfoBase *info) {
			// execute
			[info appendAdoptedProtocolWithName:@"name"];
			[info appendAdoptedProtocolWithName:@"name"];
			// verify
			info.interfaceAdoptedProtocols.count should equal(1);
			[[info.interfaceAdoptedProtocols objectAtIndex:0] nameOfObject] should equal(@"name");
		});
	});
});

describe(@"method groups registration", ^{
	it(@"should create new method group info", ^{
		runWithInterfaceInfoBase(^(InterfaceInfoBase *info) {
			// execute
			[info appendMethodGroupWithDescription:@"description"];
			// verify
			info.interfaceMethodGroups.count should equal(1);
			info.interfaceMethodGroups.lastObject should be_instance_of([MethodGroupData class]);
			[info.interfaceMethodGroups.lastObject nameOfMethodGroup] should equal(@"description");
		});
	});

	it(@"should not add new object to stack (interface needs to be able to catch method and properties registration)", ^{
		runWithInterfaceInfoBase(^(InterfaceInfoBase *info) {
			// setup
			id mock = [OCMockObject mockForClass:[Store class]];
			[[mock expect] pushRegistrationObject:[OCMArg checkWithBlock:^BOOL(id obj) {
				return [obj isKindOfClass:[MethodGroupData class]];
			}]];
			info.objectRegistrar = mock;
			// execute
			[info appendMethodGroupWithDescription:@"description"];
			// verify
			^{ [mock verify]; } should raise_exception();
		});
	});
});

describe(@"properties registration", ^{
	 it(@"should create new property info", ^{
		 runWithInterfaceInfoBase(^(InterfaceInfoBase *info) {
			// setup
			info.objectRegistrar = [OCMockObject niceMockForClass:[Store class]];
			// execute
			[info beginPropertyDefinition];
			// verify
			info.interfaceProperties.count should equal(1);
			info.interfaceProperties.lastObject should be_instance_of([PropertyInfo class]);
			[info.interfaceProperties.lastObject objectRegistrar] should equal(info.objectRegistrar);
		 });
	 });

	it(@"should push property info to registration stack", ^{
		runWithInterfaceInfoBase(^(InterfaceInfoBase *info) {
			// setup
			id mock = [OCMockObject mockForClass:[Store class]];
			[[mock expect] pushRegistrationObject:[OCMArg checkWithBlock:^BOOL(id obj) {
				return [obj isKindOfClass:[PropertyInfo class]];
			}]];
			info.objectRegistrar = mock;
			// execute
			[info beginPropertyDefinition];
			// verify
			^{ [mock verify]; } should_not raise_exception();
		});
	});
	
	it(@"should add property info to last method group if one exists", ^{
		runWithInterfaceInfoBase(^(InterfaceInfoBase *info) {
			// setup
			[info appendMethodGroupWithDescription:@""];
			// execute
			[info beginPropertyDefinition];
			// verify
			NSArray *lastMethodGroupMethods = [info.interfaceMethodGroups.lastObject methodGroupMethods];
			lastMethodGroupMethods.count should equal(1);
			lastMethodGroupMethods.lastObject should be_instance_of([PropertyInfo class]);
		});
	});
	
	it(@"should not create new method group if none exists", ^{
		runWithInterfaceInfoBase(^(InterfaceInfoBase *info) {
			// execute
			[info beginPropertyDefinition];
			// verify
			info.interfaceMethodGroups.count should equal(0);
		});
	});
});

describe(@"methods registration", ^{
	describe(@"class methods", ^{
		it(@"should create new method info and add it to class methods array", ^{
			runWithInterfaceInfoBase(^(InterfaceInfoBase *info) {
				// setup
				info.objectRegistrar = [OCMockObject niceMockForClass:[Store class]];
				// execute
				[info beginMethodDefinitionWithType:GBStoreTypes.classMethod];
				// verify
				info.interfaceClassMethods.count should equal(1);
				info.interfaceClassMethods.lastObject should be_instance_of([MethodInfo class]);
				[info.interfaceClassMethods.lastObject methodType] should equal(GBStoreTypes.classMethod);
				[info.interfaceClassMethods.lastObject objectRegistrar] should equal(info.objectRegistrar);
			});
		});

		it(@"should push method info to registration stack", ^{
			runWithInterfaceInfoBase(^(InterfaceInfoBase *info) {
				// setup
				id mock = [OCMockObject mockForClass:[Store class]];
				[[mock expect] pushRegistrationObject:[OCMArg checkWithBlock:^BOOL(id obj) {
					return ([obj isKindOfClass:[MethodInfo class]] && [[obj methodType] isEqual:GBStoreTypes.classMethod]);
				}]];
				info.objectRegistrar = mock;
				// execute
				[info beginMethodDefinitionWithType:GBStoreTypes.classMethod];
				// verify
				^{ [mock verify]; } should_not raise_exception();
			});
		});
		
		it(@"should add method info to last method group if one exists", ^{
			runWithInterfaceInfoBase(^(InterfaceInfoBase *info) {
				// setup
				[info appendMethodGroupWithDescription:@""];
				// execute
				[info beginMethodDefinitionWithType:GBStoreTypes.classMethod];
				// verify
				NSArray *lastMethodGroupMethods = [info.interfaceMethodGroups.lastObject methodGroupMethods];
				lastMethodGroupMethods.count should equal(1);
				lastMethodGroupMethods.lastObject should be_instance_of([MethodInfo class]);
			});
		});

		it(@"should not create new method group if none exists", ^{
			runWithInterfaceInfoBase(^(InterfaceInfoBase *info) {
				// execute
				[info beginMethodDefinitionWithType:GBStoreTypes.classMethod];
				// verify
				info.interfaceMethodGroups.count should equal(0);
			});
		});
	});

	describe(@"instance methods", ^{
		it(@"should create new method info and add it to instance methods array", ^{
			runWithInterfaceInfoBase(^(InterfaceInfoBase *info) {
				// setup
				info.objectRegistrar = [OCMockObject niceMockForClass:[Store class]];
				// execute
				[info beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
				// verify
				info.interfaceInstanceMethods.count should equal(1);
				info.interfaceInstanceMethods.lastObject should be_instance_of([MethodInfo class]);
				[info.interfaceInstanceMethods.lastObject methodType] should equal(GBStoreTypes.instanceMethod);
				[info.interfaceInstanceMethods.lastObject objectRegistrar] should equal(info.objectRegistrar);
			});
		});
		
		it(@"should push method info to registration stack", ^{
			runWithInterfaceInfoBase(^(InterfaceInfoBase *info) {
				// setup
				id mock = [OCMockObject mockForClass:[Store class]];
				[[mock expect] pushRegistrationObject:[OCMArg checkWithBlock:^BOOL(id obj) {
					return ([obj isKindOfClass:[MethodInfo class]] && [[obj methodType] isEqual:GBStoreTypes.instanceMethod]);
				}]];
				info.objectRegistrar = mock;
				// execute
				[info beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
				// verify
				^{ [mock verify]; } should_not raise_exception();
			});
		});
		
		it(@"should add method info to last method group if one exists", ^{
			runWithInterfaceInfoBase(^(InterfaceInfoBase *info) {
				// setup
				[info appendMethodGroupWithDescription:@""];
				// execute
				[info beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
				// verify
				NSArray *lastMethodGroupMethods = [info.interfaceMethodGroups.lastObject methodGroupMethods];
				lastMethodGroupMethods.count should equal(1);
				lastMethodGroupMethods.lastObject should be_instance_of([MethodInfo class]);
			});
		});
		
		it(@"should not create new method group if none exists", ^{
			runWithInterfaceInfoBase(^(InterfaceInfoBase *info) {
				// execute
				[info beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
				// verify
				info.interfaceMethodGroups.count should equal(0);
			});
		});
	});
});

describe(@"object cancellation", ^{
	describe(@"properties", ^{
		it(@"should remove property info from properties array", ^{
			runWithInterfaceInfoBaseWithRegistrar(^(InterfaceInfoBase *info, Store *store) {
				// setup
				[info beginPropertyDefinition];
				// execute
				[info cancelCurrentObject];
				// verify
				info.interfaceProperties.count should equal(0);
			});
		});

		it(@"should remove property info from last method group", ^{
			runWithInterfaceInfoBaseWithRegistrar(^(InterfaceInfoBase *info, Store *store) {
				// setup
				[info appendMethodGroupWithDescription:@""];
				[info beginPropertyDefinition];
				// execute
				[info cancelCurrentObject];
				// verify
				NSArray *lastMethodGroupMethods = [info.interfaceMethodGroups.lastObject methodGroupMethods];
				lastMethodGroupMethods.count should equal(0);
			});
		});
	});
	
	describe(@"class methods", ^{
		it(@"should remove method info from methods array", ^{
			runWithInterfaceInfoBaseWithRegistrar(^(InterfaceInfoBase *info, Store *store) {
				// setup
				[info beginMethodDefinitionWithType:GBStoreTypes.classMethod];
				// execute
				[info cancelCurrentObject];
				// verify
				info.interfaceClassMethods.count should equal(0);
			});
		});
		
		it(@"should remove method info from last method group", ^{
			runWithInterfaceInfoBaseWithRegistrar(^(InterfaceInfoBase *info, Store *store) {
				// setup
				[info appendMethodGroupWithDescription:@""];
				[info beginMethodDefinitionWithType:GBStoreTypes.classMethod];
				// execute
				[info cancelCurrentObject];
				// verify
				NSArray *lastMethodGroupMethods = [info.interfaceMethodGroups.lastObject methodGroupMethods];
				lastMethodGroupMethods.count should equal(0);
			});
		});
	});
	
	describe(@"instance methods", ^{
		it(@"should remove method info from methods array", ^{
			runWithInterfaceInfoBaseWithRegistrar(^(InterfaceInfoBase *info, Store *store) {
				// setup
				[info beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
				// execute
				[info cancelCurrentObject];
				// verify
				info.interfaceInstanceMethods.count should equal(0);
			});
		});
		
		it(@"should remove method info from last method group", ^{
			runWithInterfaceInfoBaseWithRegistrar(^(InterfaceInfoBase *info, Store *store) {
				// setup
				[info appendMethodGroupWithDescription:@""];
				[info beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
				// execute
				[info cancelCurrentObject];
				// verify
				NSArray *lastMethodGroupMethods = [info.interfaceMethodGroups.lastObject methodGroupMethods];
				lastMethodGroupMethods.count should equal(0);
			});
		});
	});
});

TEST_END
