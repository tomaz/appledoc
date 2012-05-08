//
//  TestCaseBase.h
//  appledoc
//
//  Created by Tomaž Kragelj on 3/13/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <OCMock/OCMock.h>
#import <Cedar/SpecHelper.h>
using namespace Cedar::Matchers;

#import "Objects+TestingPrivateAPI.h"

#define TEST_BEGIN(name) \
	SPEC_BEGIN(name) \
		describe([NSString stringWithFormat:@"%s:", #name], ^{

#define TEST_END \
		}); \
	SPEC_END
