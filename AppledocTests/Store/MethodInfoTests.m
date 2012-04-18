//
//  MethodInfoTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/17/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "TestCaseBase.h"

@interface MethodInfoTests : TestCaseBase
@end

@interface MethodInfoTests (CreationMethods)
- (void)runWithMethodInfo:(void(^)(MethodInfo *info))handler;
@end

@implementation MethodInfoTests

#pragma mark - Verify lazy initialization

- (void)testLazyInitializersWork {
	[self runWithMethodInfo:^(MethodInfo *info) {
		// execute & verify
		assertThat(info.methodResult, instanceOf([TypeInfo class]));
	}];
}

#pragma mark - beginMethodResults

- (void)testBeginMethodResultsShouldChangeCurrentRegistrationObjectToResults {
	[self runWithMethodInfo:^(MethodInfo *info) {
		// setup
		id mock = [OCMockObject mockForClass:[Store class]];
		[[mock expect] pushRegistrationObject:OCMOCK_ANY];
		info.objectRegistrar = mock;
		// execute
		[info beginMethodResults];
		// verify
		STAssertNoThrow([mock verify], nil);
	}];
}

@end

#pragma mark - 

@implementation MethodInfoTests (CreationMethods)

- (void)runWithMethodInfo:(void(^)(MethodInfo *info))handler {
	MethodInfo *info = [MethodInfo new];
	handler(info);
}

@end
