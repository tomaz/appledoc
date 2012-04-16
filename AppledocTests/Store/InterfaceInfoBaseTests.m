//
//  InterfaceInfoBaseTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/13/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "TestCaseBase.h"

@interface InterfaceInfoBase (TestingPrivateAPI)
@end

#pragma mark - 

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
		assertThatUnsignedInteger(info.interfaceAdoptedProtocols.count, equalToUnsignedInteger(2));
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
		assertThatUnsignedInteger(info.interfaceAdoptedProtocols.count, equalToUnsignedInteger(1));
		assertThat([[info.interfaceAdoptedProtocols objectAtIndex:0] nameOfObject], is(@"name"));
	}];
}

#pragma mark - beginMethodGroup

- (void)testBeginMethodGroupShouldCreateNewMethodGroup {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// execute
		[info beginMethodGroup];
		// verify
		assertThatUnsignedInteger(info.interfaceMethodGroups.count, equalToUnsignedInteger(1));
		assertThat(info.interfaceMethodGroups.lastObject, instanceOf([MethodGroupData class]));
		assertThat(info.currentRegistrationObject, equalTo(info.interfaceMethodGroups.lastObject));
	}];
}

#pragma mark - appendMethodGroupDescription:

- (void)testAppendMethodGroupDescriptionShouldAddDescriptionToCurrentMethodGroup {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// setup
		[info beginMethodGroup];
		// execute
		[info appendMethodGroupDescription:@"description"];
		// verify
		assertThat([[info.interfaceMethodGroups lastObject] nameOfMethodGroup], equalTo(@"description"));
	}];
}

- (void)testAppendMethodGroupDescriptionShouldUseLastGivenDescriptionForCurrentMethodGroup {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// setup
		[info beginMethodGroup];
		// execute
		[info appendMethodGroupDescription:@"value1"];
		[info appendMethodGroupDescription:@"value2"];
		// verify
		assertThat([info.interfaceMethodGroups.lastObject nameOfMethodGroup], equalTo(@"value2"));
	}];
}

- (void)testAppendMethodGroupDescriptionShouldIgnoreIfCurrentRegistrationObjectIsNotMethodGroup {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// execute
		[info appendMethodGroupDescription:@"value1"];
		// verify - just validates no method group is created
		assertThatUnsignedInteger(info.interfaceMethodGroups.count, equalToUnsignedInteger(0));
	}];
}

#pragma mark - beginPropertyDefinition

- (void)testBeginPropertyDefinitionShouldCreateAndAddPropertyInfoToPropertiesListAndCurrentRegistrationObject {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// execute
		[info beginPropertyDefinition];
		// verify
		assertThatUnsignedInteger([info.interfaceMethodGroups count], equalToUnsignedInteger(0)); // we don't add new method group explicitly!
		assertThatUnsignedInteger(info.interfaceProperties.count, equalToUnsignedInteger(1));
		assertThat(info.interfaceProperties.lastObject, instanceOf([PropertyInfo class]));
		assertThat(info.currentRegistrationObject, equalTo(info.interfaceProperties.lastObject));
	}];
}

- (void)testBeginPropertyDefinitionShouldAddPropertyToLastMethodGroup {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// setup
		[info beginMethodGroup];
		// execute
		[info beginPropertyDefinition];
		// verify
		NSArray *lastMethodGroupMethods = [info.interfaceMethodGroups.lastObject methodGroupMethods];
		assertThatUnsignedInteger([lastMethodGroupMethods count], equalToUnsignedInteger(1));
		assertThat(lastMethodGroupMethods.lastObject, instanceOf([PropertyInfo class]));
		assertThat(info.currentRegistrationObject, equalTo(info.interfaceProperties.lastObject));
	}];
}

#pragma mark - beginMethodDefinitionWithType:

- (void)testBeginMethodDefinitionWithTypeShouldCreateAndAddClassMethodInfoToClassMethodsListAndCurrentRegistrationObject {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// execute
		[info beginMethodDefinitionWithType:GBStoreTypes.classMethod];
		// verify
		assertThatUnsignedInteger([info.interfaceMethodGroups count], equalToUnsignedInteger(0)); // we don't add new method group explicitly!
		assertThatUnsignedInteger(info.interfaceClassMethods.count, equalToUnsignedInteger(1));
		assertThat(info.interfaceClassMethods.lastObject, instanceOf([MethodInfo class]));
		assertThat([info.interfaceClassMethods.lastObject methodType], equalTo(GBStoreTypes.classMethod));
		assertThat(info.currentRegistrationObject, equalTo(info.interfaceClassMethods.lastObject));
	}];
}

- (void)testBeginMethodDefinitionWithTypeShouldCreateAndAddInstanceMethodInfoToInstanceMethodsListAndCurrentRegistrationObject {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// execute
		[info beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
		// verify
		assertThatUnsignedInteger([info.interfaceMethodGroups count], equalToUnsignedInteger(0)); // we don't add new method group explicitly!
		assertThatUnsignedInteger(info.interfaceInstanceMethods.count, equalToUnsignedInteger(1));
		assertThat(info.interfaceInstanceMethods.lastObject, instanceOf([MethodInfo class]));
		assertThat([info.interfaceInstanceMethods.lastObject methodType], equalTo(GBStoreTypes.instanceMethod));
		assertThat(info.currentRegistrationObject, equalTo(info.interfaceInstanceMethods.lastObject));
	}];
}

- (void)testBeginMethodDefinitionWithTypeShouldAddClassMethodInfoToLastMethodGroup {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// setup
		[info beginMethodGroup];
		// execute
		[info beginMethodDefinitionWithType:GBStoreTypes.classMethod];
		// verify
		NSArray *lastMethodGroupMethods = [info.interfaceMethodGroups.lastObject methodGroupMethods];
		assertThatUnsignedInteger([lastMethodGroupMethods count], equalToUnsignedInteger(1));
		assertThat(lastMethodGroupMethods.lastObject, instanceOf([MethodInfo class]));
		assertThat(info.currentRegistrationObject, equalTo(info.interfaceClassMethods.lastObject));
	}];
}

- (void)testBeginMethodDefinitionWithTypeShouldAddInstanceMethodInfoToLastMethodGroup {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// setup
		[info beginMethodGroup];
		// execute
		[info beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
		// verify
		NSArray *lastMethodGroupMethods = [info.interfaceMethodGroups.lastObject methodGroupMethods];
		assertThatUnsignedInteger([lastMethodGroupMethods count], equalToUnsignedInteger(1));
		assertThat(lastMethodGroupMethods.lastObject, instanceOf([MethodInfo class]));
		assertThat(info.currentRegistrationObject, equalTo(info.interfaceInstanceMethods.lastObject));
	}];
}

#pragma mark - endCurrentObject

- (void)testEndCurrentObjectShouldEndLastMethodGroupIfNoMethodOrPropertyWasRegistered {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// setup
		[info beginMethodGroup];
		[info appendMethodGroupDescription:@"description"];
		// execute
		[info endCurrentObject];
		// verify
		assertThatUnsignedInteger(info.interfaceMethodGroups.count, equalToUnsignedInteger(0));
	}];
}

- (void)testEndCurrentObjectShouldEndLastPropertyInfo {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// setup
		[info beginMethodGroup];
		[info beginPropertyDefinition];
		// execute
		[info endCurrentObject];
		// verify
		assertThatUnsignedInteger(info.interfaceProperties.count, equalToUnsignedInteger(1));
		assertThat(info.currentRegistrationObject, equalTo(info.interfaceMethodGroups.lastObject));
	}];
}

- (void)testCancelCurrentObjectShouldEndClassMethodInfo {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// setup
		[info beginMethodGroup];
		[info beginMethodDefinitionWithType:GBStoreTypes.classMethod];
		// execute
		[info endCurrentObject];
		// verify
		assertThatUnsignedInteger(info.interfaceClassMethods.count, equalToUnsignedInteger(1));
		assertThat(info.currentRegistrationObject, equalTo(info.interfaceMethodGroups.lastObject));
	}];
}

- (void)testCancelCurrentObjectShouldEndInstanceMethodInfo {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// setup
		[info beginMethodGroup];
		[info beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
		// execute
		[info endCurrentObject];
		// verify
		assertThatUnsignedInteger(info.interfaceInstanceMethods.count, equalToUnsignedInteger(1));
		assertThat(info.currentRegistrationObject, equalTo(info.interfaceMethodGroups.lastObject));
	}];
}

#pragma mark - cancelCurrentObject

- (void)testCancelCurrentObjectShouldRemoveMethodGroup {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// setup
		[info beginMethodGroup];
		// execute
		[info cancelCurrentObject];
		// verify
		assertThatUnsignedInteger(info.interfaceMethodGroups.count, equalToUnsignedInteger(0));
		assertThat(info.currentRegistrationObject, equalTo(nil));
	}];
}

- (void)testCancelCurrentObjectShouldRemovePropertyInfo {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// setup
		[info beginMethodGroup];
		[info beginPropertyDefinition];
		// execute
		[info cancelCurrentObject];
		// verify
		assertThatUnsignedInteger([[info.interfaceMethodGroups.lastObject methodGroupMethods] count], equalToUnsignedInteger(0));
		assertThatUnsignedInteger(info.interfaceProperties.count, equalToUnsignedInteger(0));
		assertThat(info.currentRegistrationObject, equalTo(info.interfaceMethodGroups.lastObject));
	}];
}

- (void)testCancelCurrentObjectShouldRemoveClassMethodInfo {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// setup
		[info beginMethodGroup];
		[info beginMethodDefinitionWithType:GBStoreTypes.classMethod];
		// execute
		[info cancelCurrentObject];
		// verify
		assertThatUnsignedInteger([[info.interfaceMethodGroups.lastObject methodGroupMethods] count], equalToUnsignedInteger(0));
		assertThatUnsignedInteger(info.interfaceClassMethods.count, equalToUnsignedInteger(0));
		assertThat(info.currentRegistrationObject, equalTo(info.interfaceMethodGroups.lastObject));
	}];
}

- (void)testCancelCurrentObjectShouldRemoveInstanceMethodInfo {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// setup
		[info beginMethodGroup];
		[info beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
		// execute
		[info cancelCurrentObject];
		// verify
		assertThatUnsignedInteger([[info.interfaceMethodGroups.lastObject methodGroupMethods] count], equalToUnsignedInteger(0));
		assertThatUnsignedInteger(info.interfaceInstanceMethods.count, equalToUnsignedInteger(0));
		assertThat(info.currentRegistrationObject, equalTo(info.interfaceMethodGroups.lastObject));
	}];
}

@end

#pragma mark - 

@implementation InterfaceInfoBaseTests (CreationMethods)

- (void)runWithInterfaceInfoBase:(void(^)(InterfaceInfoBase *info))handler {
	InterfaceInfoBase *info = [InterfaceInfoBase new];
	handler(info);
}

@end
