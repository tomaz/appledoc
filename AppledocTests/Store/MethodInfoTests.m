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
		assertThat(info.methodArguments, instanceOf([NSMutableArray class]));
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

#pragma mark - beginMethodArgument

- (void)testBeginMethodArgumentShouldCreateNewMethodArgument {
	[self runWithMethodInfo:^(MethodInfo *info) {
		// setup
		id mock = [OCMockObject mockForClass:[Store class]];
		[[mock expect] pushRegistrationObject:OCMOCK_ANY];
		info.objectRegistrar = mock;
		// execute
		[info beginMethodArgument];
		// verify
		STAssertNoThrow([mock verify], nil);
		assertThatInt(info.methodArguments.count, equalToInt(1));
		assertThat([info.methodArguments lastObject], instanceOf([MethodArgumentInfo class]));
		assertThat([[info.methodArguments lastObject] objectRegistrar], equalTo(mock));
	}];
}

#pragma mark - cancelCurrentObject

- (void)testCancelCurrentObjectShouldRemoveMethodArgument {
	[self runWithMethodInfo:^(MethodInfo *info) {
		// setup
		[info beginMethodArgument];
		id mock = [OCMockObject niceMockForClass:[Store class]];
		[[[mock stub] andReturn:info.methodArguments.lastObject] currentRegistrationObject];
		info.objectRegistrar = mock;
		// execute
		[info cancelCurrentObject];
		// verify
		assertThatInt(info.methodArguments.count, equalToInt(0));
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
