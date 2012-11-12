//
//  TestCaseBase.h
//  appledoc
//
//  Created by Tomaž Kragelj on 3/13/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <OCMock/OCMock.h>


#pragma mark - OCMockito

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#ifdef given
#	undef given
#	define given(methodCall) MKTGivenWithLocation([SpecHelper specHelper], __FILE__, __LINE__, methodCall)
#endif


#pragma mark - Cedar

#import <Cedar/SpecHelper.h>
using namespace Cedar::Matchers;

#define gbcatch(code) ^{ code; } should_not raise_exception()
#define gbfail(code) ^{ code; } should raise_exception()

#define TEST_BEGIN(name) \
	SPEC_BEGIN(name) \
		describe([NSString gb_format:@"%s:", #name], ^{

#define TEST_END \
		}); \
	SPEC_END
	

#pragma mark - Appledoc

#import "Objects+TestingPrivateAPI.h"
