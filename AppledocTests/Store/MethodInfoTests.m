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
		[info beginMethodResults];
		// verify
//		assertThatUnsignedInteger(info.registrationStack.count, equalToUnsignedInteger(1));
//		assertThat(info.currentRegistrationObject, instanceOf([TypeInfo class]));
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
