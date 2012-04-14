//
//  ObjectInfoBaseTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/14/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectInfoBase.h"
#import "TestCaseBase.h"

@interface ObjectInfoBaseTests : TestCaseBase
@end

@interface ObjectInfoBaseTests (CreationMethods)
- (void)runWithObjectInfoBase:(void(^)(ObjectInfoBase *info))handler;
@end

@implementation ObjectInfoBaseTests

#pragma mark - pushRegistrationObject:

- (void)testPushRegistrationObjectShouldAddGivenObjectToTheEndOfRegistrationStack {
	[self runWithObjectInfoBase:^(ObjectInfoBase *info) {
		// setup
		id mock = [OCMockObject mockForClass:[ObjectInfoBase class]];
		// execute
		[info pushRegistrationObject:mock];
		// verify
		assertThatUnsignedInteger(info.registrationStack.count, equalToUnsignedInteger(1));
		assertThat([info.registrationStack lastObject], equalTo(mock));
	}];
}

- (void)testPushRegistrationObjectShouldAddAllObjectsToRegistrationStackInGivenOrder {
	[self runWithObjectInfoBase:^(ObjectInfoBase *info) {
		// setup
		id mock1 = [OCMockObject mockForClass:[ObjectInfoBase class]];
		id mock2 = [OCMockObject mockForClass:[ObjectInfoBase class]];
		[info pushRegistrationObject:mock1];
		// execute
		[info pushRegistrationObject:mock2];
		// verify
		assertThatUnsignedInteger(info.registrationStack.count, equalToUnsignedInteger(2));
		assertThat([info.registrationStack objectAtIndex:0], equalTo(mock1));
		assertThat([info.registrationStack objectAtIndex:1], equalTo(mock2));
	}];
}

#pragma mark - popRegistrationStack

- (void)testPopRegistrationObjectShouldRemoveLastObjectFromRegistrationStackLeavingPreviousObjectsUntouched {
	[self runWithObjectInfoBase:^(ObjectInfoBase *info) {
		// setup
		id mock1 = [OCMockObject mockForClass:[ObjectInfoBase class]];
		id mock2 = [OCMockObject mockForClass:[ObjectInfoBase class]];
		[info pushRegistrationObject:mock1];
		[info pushRegistrationObject:mock2];
		// execute
		id poppedObject = [info popRegistrationObject];
		// verify
		assertThatUnsignedInteger(info.registrationStack.count, equalToUnsignedInteger(1));
		assertThat([info.registrationStack lastObject], equalTo(mock1));
		assertThat(poppedObject, equalTo(mock2));
	}];
}

- (void)testPopRegistrationObjectShouldRemoveLastObjectFromRegistrationStackEmptyingStack {
	[self runWithObjectInfoBase:^(ObjectInfoBase *info) {
		// setup
		id mock = [OCMockObject mockForClass:[ObjectInfoBase class]];
		[info pushRegistrationObject:mock];
		// execute
		id poppedObject = [info popRegistrationObject];
		// verify
		assertThatUnsignedInteger(info.registrationStack.count, equalToUnsignedInteger(0));
		assertThat(poppedObject, equalTo(mock));
	}];
}

- (void)testPopRegistrationObjectShouldReturnNilIfStackIsEmpty {
	[self runWithObjectInfoBase:^(ObjectInfoBase *info) {
		// execute
		id poppedObject = [info popRegistrationObject];
		// verify
		assertThatUnsignedInteger(info.registrationStack.count, equalToUnsignedInteger(0));
		assertThat(poppedObject, equalTo(nil));
	}];
}

#pragma mark - currentRegistrationObject

- (void)testCurrentRegistrationObjectShouldBeNilIfStackIsEmpty {
	[self runWithObjectInfoBase:^(ObjectInfoBase *info) {
		// execute & verify
		assertThat(info.currentRegistrationObject, equalTo(nil));
	}];
}

- (void)testCurrentRegistrationObjectShouldPointToOneAndOnlyObjectIfStackContainsSingleObject {
	[self runWithObjectInfoBase:^(ObjectInfoBase *info) {
		// setup
		id mock = [OCMockObject mockForClass:[ObjectInfoBase class]];
		[info pushRegistrationObject:mock];
		// execute & verify
		assertThat(info.currentRegistrationObject, equalTo(mock));
	}];
}

- (void)testCurrentRegistrationObjectShouldPointToLastObjectIfStackContainsMultipleObjects {
	[self runWithObjectInfoBase:^(ObjectInfoBase *info) {
		// setup
		id mock1 = [OCMockObject mockForClass:[ObjectInfoBase class]];
		id mock2 = [OCMockObject mockForClass:[ObjectInfoBase class]];
		[info pushRegistrationObject:mock1];
		[info pushRegistrationObject:mock2];
		// execute & verify
		assertThat(info.currentRegistrationObject, equalTo(mock2));
	}];
}

@end

#pragma mark - 

@implementation ObjectInfoBaseTests (CreationMethods)

- (void)runWithObjectInfoBase:(void(^)(ObjectInfoBase *info))handler {
	ObjectInfoBase *info = [ObjectInfoBase new];
	handler(info);
}

@end
