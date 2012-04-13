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
		assertThat([info.interfaceMethodGroups lastObject], instanceOf([MethodGroupData class]));
		assertThat(info.currentRegistrationObject, equalTo([info.interfaceMethodGroups lastObject]));
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
		assertThat([[info.interfaceMethodGroups lastObject] nameOfMethodGroup], equalTo(@"value2"));
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

#pragma mark - endCurrentObject

- (void)testEndCurrentObjectShouldRemoveLastMethodGroupIfEmpty {
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

@end

#pragma mark - 

@implementation InterfaceInfoBaseTests (CreationMethods)

- (void)runWithInterfaceInfoBase:(void(^)(InterfaceInfoBase *info))handler {
	InterfaceInfoBase *info = [InterfaceInfoBase new];
	handler(info);
}

@end
