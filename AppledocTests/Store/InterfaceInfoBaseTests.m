//
//  InterfaceInfoBaseTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/13/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "TestCaseBase.h"

@interface InterfaceInfoBaseTests : TestCaseBase
@end

@interface InterfaceInfoBaseTests (CreationMethods)
- (void)runWithInterfaceInfoBase:(void(^)(InterfaceInfoBase *info))handler;
@end

@implementation InterfaceInfoBaseTests

#pragma mark - Lazy instantiation

- (void)testLazyInstantiationWorks {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// execute & verify
		assertThat(info.interfaceAdoptedProtocols, instanceOf([NSMutableArray class]));
		assertThat(info.interfaceMethodGroups, instanceOf([NSMutableArray class]));
		assertThat(info.interfaceProperties, instanceOf([NSMutableArray class]));
		assertThat(info.interfaceInstanceMethods, instanceOf([NSMutableArray class]));
		assertThat(info.interfaceClassMethods, instanceOf([NSMutableArray class]));
	}];
}

#pragma mark - appendAdoptedProtocolWithName:

- (void)testAppendAdoptedProtocolWithNameShouldAddAllProtocols {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// execute
		[info appendAdoptedProtocolWithName:@"name1"];
		[info appendAdoptedProtocolWithName:@"name2"];
		// verify
		assertThatInt(info.interfaceAdoptedProtocols.count, equalToInt(2));
		assertThat([[info.interfaceAdoptedProtocols objectAtIndex:0] nameOfObject], is(@"name1"));
		assertThat([[info.interfaceAdoptedProtocols objectAtIndex:1] nameOfObject], is(@"name2"));
	}];
}

- (void)testAppendAdoptedProtocolWithNameShouldIgnoreExistingNames {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// execute
		[info appendAdoptedProtocolWithName:@"name"];
		[info appendAdoptedProtocolWithName:@"name"];
		// verify
		assertThatInt(info.interfaceAdoptedProtocols.count, equalToInt(1));
		assertThat([[info.interfaceAdoptedProtocols objectAtIndex:0] nameOfObject], is(@"name"));
	}];
}

#pragma mark - appendMethodGroupWithDescription:

- (void)testAppendMethodGroupWithDescriptionShouldCreateNewMethodGroupInfo {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// setup
		id mock = [OCMockObject mockForClass:[Store class]];
		[[mock expect] pushRegistrationObject:[OCMArg checkWithBlock:^BOOL(id obj) {
			return [obj isKindOfClass:[MethodGroupData class]];
		}]];
		info.objectRegistrar = mock;
		// execute
		[info appendMethodGroupWithDescription:@"description"];
		// verify
		STAssertThrows([mock verify], nil); // we must not add this object to stack as interface needs to be able to catch method and properties registrations!
		assertThatInt(info.interfaceMethodGroups.count, equalToInt(1));
		assertThat(info.interfaceMethodGroups.lastObject, instanceOf([MethodGroupData class]));
		assertThat([info.interfaceMethodGroups.lastObject nameOfMethodGroup], equalTo(@"description"));
	}];
}

#pragma mark - beginPropertyDefinition

- (void)testBeginPropertyDefinitionShouldCreateNewPropertyInfoAndPushItToRegistrationStack {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// setup
		id mock = [OCMockObject mockForClass:[Store class]];
		[[mock expect] pushRegistrationObject:[OCMArg checkWithBlock:^BOOL(id obj) {
			return [obj isKindOfClass:[PropertyInfo class]];
		}]];
		info.objectRegistrar = mock;
		// execute
		[info beginPropertyDefinition];
		// verify
		STAssertNoThrow([mock verify], nil);
		assertThatInt([info.interfaceMethodGroups count], equalToInt(0)); // we don't add new method group explicitly!
		assertThatInt(info.interfaceProperties.count, equalToInt(1));
		assertThat(info.interfaceProperties.lastObject, instanceOf([PropertyInfo class]));
		assertThat([info.interfaceProperties.lastObject objectRegistrar], equalTo(mock));
	}];
}

- (void)testBeginPropertyDefinitionShouldAddPropertyToLastMethodGroup {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// setup
		[info appendMethodGroupWithDescription:@""];
		// execute
		[info beginPropertyDefinition];
		// verify
		NSArray *lastMethodGroupMethods = [info.interfaceMethodGroups.lastObject methodGroupMethods];
		assertThatInt([lastMethodGroupMethods count], equalToInt(1));
		assertThat(lastMethodGroupMethods.lastObject, instanceOf([PropertyInfo class]));
	}];
}

#pragma mark - beginMethodDefinitionWithType:

- (void)testBeginMethodDefinitionWithTypeShouldCreateNewClassMethodInfoAndPushItToRegistrationStack {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// setup
		id mock = [OCMockObject mockForClass:[Store class]];
		[[mock expect] pushRegistrationObject:[OCMArg checkWithBlock:^BOOL(id obj) {
			return ([obj isKindOfClass:[MethodInfo class]] && [[obj methodType] isEqual:GBStoreTypes.classMethod]);
		}]];
		info.objectRegistrar = mock;
		// execute
		[info beginMethodDefinitionWithType:GBStoreTypes.classMethod];
		// verify
		STAssertNoThrow([mock verify], nil);
		assertThatInt([info.interfaceMethodGroups count], equalToInt(0)); // we don't add new method group implicitly!
		assertThatInt(info.interfaceClassMethods.count, equalToInt(1));
		assertThatInt(info.interfaceInstanceMethods.count, equalToInt(0));
		assertThat(info.interfaceClassMethods.lastObject, instanceOf([MethodInfo class]));
		assertThat([info.interfaceClassMethods.lastObject methodType], equalTo(GBStoreTypes.classMethod));
		assertThat([info.interfaceClassMethods.lastObject objectRegistrar], equalTo(mock));
	}];
}

- (void)testBeginMethodDefinitionWithTypeShouldCreateNewInstanceMethodInfoAndPushItToRegistrationStack {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// setup
		id mock = [OCMockObject mockForClass:[Store class]];
		[[mock expect] pushRegistrationObject:[OCMArg checkWithBlock:^BOOL(id obj) {
			return ([obj isKindOfClass:[MethodInfo class]] && [[obj methodType] isEqual:GBStoreTypes.instanceMethod]);
		}]];
		info.objectRegistrar = mock;
		// execute
		[info beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
		// verify
		STAssertNoThrow([mock verify], nil);
		assertThatInt([info.interfaceMethodGroups count], equalToInt(0)); // we don't add new method group implicitly!
		assertThatInt(info.interfaceInstanceMethods.count, equalToInt(1));
		assertThatInt(info.interfaceClassMethods.count, equalToInt(0));
		assertThat(info.interfaceInstanceMethods.lastObject, instanceOf([MethodInfo class]));
		assertThat([info.interfaceInstanceMethods.lastObject methodType], equalTo(GBStoreTypes.instanceMethod));
		assertThat([info.interfaceInstanceMethods.lastObject objectRegistrar], equalTo(mock));
	}];
}

- (void)testBeginMethodDefinitionWithTypeShouldAddClassMethodInfoToLastMethodGroup {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// setup
		[info appendMethodGroupWithDescription:@""];
		// execute
		[info beginMethodDefinitionWithType:GBStoreTypes.classMethod];
		// verify
		NSArray *lastMethodGroupMethods = [info.interfaceMethodGroups.lastObject methodGroupMethods];
		assertThatInt([lastMethodGroupMethods count], equalToInt(1));
		assertThat(lastMethodGroupMethods.lastObject, instanceOf([MethodInfo class]));
	}];
}

- (void)testBeginMethodDefinitionWithTypeShouldAddInstanceMethodInfoToLastMethodGroup {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// setup
		[info appendMethodGroupWithDescription:@""];
		// execute
		[info beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
		// verify
		NSArray *lastMethodGroupMethods = [info.interfaceMethodGroups.lastObject methodGroupMethods];
		assertThatInt([lastMethodGroupMethods count], equalToInt(1));
		assertThat(lastMethodGroupMethods.lastObject, instanceOf([MethodInfo class]));
	}];
}

#pragma mark - cancelCurrentObject

- (void)testCancelCurrentObjectShouldRemovePropertyInfo {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// setup
		[info appendMethodGroupWithDescription:@""];
		[info beginPropertyDefinition];
		id mock = [OCMockObject niceMockForClass:[Store class]];
		[[[mock stub] andReturn:info.interfaceProperties.lastObject] currentRegistrationObject];
		info.objectRegistrar = mock;
		// execute
		[info cancelCurrentObject];
		// verify
		NSArray *lastMethodGroupMethods = [info.interfaceMethodGroups.lastObject methodGroupMethods];
		assertThatInt(lastMethodGroupMethods.count, equalToInt(0));
		assertThatInt(info.interfaceProperties.count, equalToInt(0));
	}];
}

- (void)testCancelCurrentObjectShouldRemoveClassMethodInfo {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// setup
		[info appendMethodGroupWithDescription:@""];
		[info beginMethodDefinitionWithType:GBStoreTypes.classMethod];
		id mock = [OCMockObject niceMockForClass:[Store class]];
		[[[mock stub] andReturn:info.interfaceClassMethods.lastObject] currentRegistrationObject];
		info.objectRegistrar = mock;
		// execute
		[info cancelCurrentObject];
		// verify
		NSArray *lastMethodGroupMethods = [info.interfaceMethodGroups.lastObject methodGroupMethods];
		assertThatInt(lastMethodGroupMethods.count, equalToInt(0));
		assertThatInt(info.interfaceClassMethods.count, equalToInt(0));
	}];
}

- (void)testCancelCurrentObjectShouldRemoveInstanceMethodInfo {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// setup
		[info appendMethodGroupWithDescription:@""];
		[info beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
		id mock = [OCMockObject niceMockForClass:[Store class]];
		[[[mock stub] andReturn:info.interfaceInstanceMethods.lastObject] currentRegistrationObject];
		info.objectRegistrar = mock;
		// execute
		[info cancelCurrentObject];
		// verify
		NSArray *lastMethodGroupMethods = [info.interfaceMethodGroups.lastObject methodGroupMethods];
		assertThatInt(lastMethodGroupMethods.count, equalToInt(0));
		assertThatInt(info.interfaceInstanceMethods.count, equalToInt(0));
	}];
}

@end

#pragma mark - 

@implementation InterfaceInfoBaseTests (CreationMethods)

- (void)runWithInterfaceInfoBase:(void(^)(InterfaceInfoBase *info))handler {
	InterfaceInfoBase *info = [[InterfaceInfoBase alloc] initWithRegistrar:nil];
	handler(info);
}

@end
