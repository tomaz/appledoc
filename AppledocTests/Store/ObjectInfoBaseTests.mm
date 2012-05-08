//
//  ObjectInfoBaseTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/14/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectInfoBase.h"
#import "TestCaseBase.hh"

static void runWithObjectInfoBase(void(^handler)(ObjectInfoBase *info)) {
	ObjectInfoBase *info = [[ObjectInfoBase alloc] init];
	handler(info);
	[info release];
}

TEST_BEGIN(ObjectInfoBaseTests)

describe(@"push object to registration stack", ^{
	it(@"should forward request to assigned store registrar", ^{
		runWithObjectInfoBase(^(ObjectInfoBase *info) {
			// setup
			id child = @"child";
			id registrar = [OCMockObject mockForProtocol:@protocol(StoreRegistrar)];
			[[registrar expect] pushRegistrationObject:child];
			info.objectRegistrar = registrar;
			// execute
			[info pushRegistrationObject:child];
			// verify
			^{ [registrar verify]; } should_not raise_exception();
		});
	});
});

describe(@"pop object from registration stack", ^{
	it(@"should forward request to assigned store registrar", ^{
		runWithObjectInfoBase(^(ObjectInfoBase *info) {
			// setup
			id child = @"child";
			id registrar = [OCMockObject mockForProtocol:@protocol(StoreRegistrar)];
			[[[registrar expect] andReturn:child] popRegistrationObject];
			info.objectRegistrar = registrar;
			// execute
			id poppedObject = [info popRegistrationObject];
			// verify
			^{ [registrar verify]; } should_not raise_exception();
			poppedObject should equal(child);
		});
	});
});

describe(@"pop object from registration stack", ^{
	it(@"should forward request to assigned store registrar", ^{
		runWithObjectInfoBase(^(ObjectInfoBase *info) {
			// setup
			id child = @"child";
			id registrar = [OCMockObject mockForProtocol:@protocol(StoreRegistrar)];
			[[[registrar expect] andReturn:child] currentRegistrationObject];
			info.objectRegistrar = registrar;
			// execute
			id currentObject = [info currentRegistrationObject];
			// verify
			^{ [registrar verify]; } should_not raise_exception();
			currentObject should equal(child);
		});
	});
});

describe(@"pop object from registration stack", ^{
	it(@"should forward request to assigned store registrar", ^{
		runWithObjectInfoBase(^(ObjectInfoBase *info) {
			// setup
			id registrar = [OCMockObject mockForProtocol:@protocol(StoreRegistrar)];
			[[registrar expect] expectCurrentRegistrationObjectRespondTo:@selector(currentRegistrationObject)];
			info.objectRegistrar = registrar;
			// execute
			[info expectCurrentRegistrationObjectRespondTo:@selector(currentRegistrationObject)];
			// verify
			^{ [registrar verify]; } should_not raise_exception();
		});
	});
});

describe(@"pop object from registration stack", ^{
	it(@"should forward request to assigned store registrar", ^{
		runWithObjectInfoBase(^(ObjectInfoBase *info) {
			// setup
			id registrar = [OCMockObject mockForProtocol:@protocol(StoreRegistrar)];
			[[registrar expect] doesCurrentRegistrationObjectRespondTo:@selector(currentRegistrationObject)];
			info.objectRegistrar = registrar;
			// execute
			[info doesCurrentRegistrationObjectRespondTo:@selector(currentRegistrationObject)];
			// verify
			^{ [registrar verify]; } should_not raise_exception();
		});
	});
});

TEST_END
