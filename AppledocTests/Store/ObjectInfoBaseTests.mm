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

describe(@"push object to registration stack:", ^{
	it(@"should forward request to assigned store registrar", ^{
		runWithObjectInfoBase(^(ObjectInfoBase *info) {
			// setup
			id child = @"child";
			id registrar = mockProtocol(@protocol(StoreRegistrar));
			info.objectRegistrar = registrar;
			// execute
			[info pushRegistrationObject:child];
			// verify
			gbcatch([verify(registrar) pushRegistrationObject:child]);
		});
	});
});

describe(@"pop object from registration stack:", ^{
	it(@"should forward request to assigned store registrar", ^{
		runWithObjectInfoBase(^(ObjectInfoBase *info) {
			// setup
			id child = @"child";
			id registrar = mockProtocol(@protocol(StoreRegistrar));
			info.objectRegistrar = registrar;
			// execute
			[info popRegistrationObject];
			// verify
			gbcatch([verify(registrar) popRegistrationObject]);
		});
	});
});

describe(@"current registration object:", ^{
	it(@"should forward request to assigned store registrar", ^{
		runWithObjectInfoBase(^(ObjectInfoBase *info) {
			// setup
			id child = @"child";
			id registrar = mockProtocol(@protocol(StoreRegistrar));
			info.objectRegistrar = registrar;
			// execute
			[info currentRegistrationObject];
			// verify
			gbcatch([verify(registrar) currentRegistrationObject]);
		});
	});
});

describe(@"expect current registration object respond to:", ^{
	it(@"should forward request to assigned store registrar", ^{
		runWithObjectInfoBase(^(ObjectInfoBase *info) {
			// setup
			id registrar = mockProtocol(@protocol(StoreRegistrar));
			info.objectRegistrar = registrar;
			// execute
			[info expectCurrentRegistrationObjectRespondTo:@selector(currentRegistrationObject)];
			// verify
			gbcatch([verify(registrar) expectCurrentRegistrationObjectRespondTo:@selector(currentRegistrationObject)]);
		});
	});
});

describe(@"does current registration object respond to:", ^{
	it(@"should forward request to assigned store registrar", ^{
		runWithObjectInfoBase(^(ObjectInfoBase *info) {
			// setup
			id registrar = mockProtocol(@protocol(StoreRegistrar));
			info.objectRegistrar = registrar;
			// execute
			[info doesCurrentRegistrationObjectRespondTo:@selector(currentRegistrationObject)];
			// verify
			gbcatch([verify(registrar) doesCurrentRegistrationObjectRespondTo:@selector(currentRegistrationObject)]);
		});
	});
});

TEST_END
