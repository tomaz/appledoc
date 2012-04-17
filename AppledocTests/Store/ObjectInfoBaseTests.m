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

- (void)testPushRegistrationObjectShouldForwardRequestToAssignedStoreRegistrar {
	[self runWithObjectInfoBase:^(ObjectInfoBase *info) {
		// setup
		id child = @"child";
		id registrar = [OCMockObject mockForProtocol:@protocol(StoreRegistrar)];
		[[registrar expect] pushRegistrationObject:child];
		info.objectRegistrar = registrar;
		// execute
		[info pushRegistrationObject:child];
		// verify
		STAssertNoThrow([registrar verify], nil);
	}];
}

#pragma mark - popRegistrationStack

- (void)testPopRegistrationObjectShouldForwardRequestToAssignedStoreRegistrar {
	[self runWithObjectInfoBase:^(ObjectInfoBase *info) {
		// setup
		id child = @"child";
		id registrar = [OCMockObject mockForProtocol:@protocol(StoreRegistrar)];
		[[[registrar expect] andReturn:child] popRegistrationObject];
		info.objectRegistrar = registrar;
		// execute
		id poppedObject = [info popRegistrationObject];
		// verify
		STAssertNoThrow([registrar verify], nil);
		assertThat(poppedObject, equalTo(child));
	}];
}

#pragma mark - currentRegistrationObject

- (void)testCurrentRegistrationObjectShouldForwardRequestToAssignedStoreRegistrar {
	[self runWithObjectInfoBase:^(ObjectInfoBase *info) {
		// setup
		id child = @"child";
		id registrar = [OCMockObject mockForProtocol:@protocol(StoreRegistrar)];
		[[[registrar expect] andReturn:child] currentRegistrationObject];
		info.objectRegistrar = registrar;
		// execute
		id currentObject = [info currentRegistrationObject];
		// verify
		STAssertNoThrow([registrar verify], nil);
		assertThat(currentObject, equalTo(child));
	}];
}

#pragma mark - expectCurrentRegistrationObjectRespondTo:

- (void)testExpectCurrentRegistrationObjectRespondToShouldForwardRequestToAssignedStoreRegistrar {
	[self runWithObjectInfoBase:^(ObjectInfoBase *info) {
		// setup
		id registrar = [OCMockObject mockForProtocol:@protocol(StoreRegistrar)];
		[[registrar expect] expectCurrentRegistrationObjectRespondTo:@selector(currentRegistrationObject)];
		info.objectRegistrar = registrar;
		// execute
		[info expectCurrentRegistrationObjectRespondTo:@selector(currentRegistrationObject)];
		// verify
		STAssertNoThrow([registrar verify], nil);
	}];
}

#pragma mark - doesCurrentRegistrationObjectRespondTo:

- (void)testDoesCurrentRegistrationObjectRespondToShouldForwardRequestToAssignedStoreRegistrar {
	[self runWithObjectInfoBase:^(ObjectInfoBase *info) {
		// setup
		id registrar = [OCMockObject mockForProtocol:@protocol(StoreRegistrar)];
		[[registrar expect] doesCurrentRegistrationObjectRespondTo:@selector(currentRegistrationObject)];
		info.objectRegistrar = registrar;
		// execute
		[info doesCurrentRegistrationObjectRespondTo:@selector(currentRegistrationObject)];
		// verify
		STAssertNoThrow([registrar verify], nil);
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
