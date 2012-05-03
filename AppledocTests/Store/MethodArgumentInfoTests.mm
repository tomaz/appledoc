//
//  MethodArgumentInfoTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/17/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "TestCaseBase.h"

@interface MethodArgumentInfoTests : TestCaseBase
@end

@interface MethodArgumentInfoTests (CreationMethods)
- (void)runWithMethodArgumentInfo:(void(^)(MethodArgumentInfo *info))handler;
@end

@implementation MethodArgumentInfoTests

#pragma mark - Verify lazy initialization

- (void)testLazyInitializersWork {
	[self runWithMethodArgumentInfo:^(MethodArgumentInfo *info) {
		// execute & verify
		assertThat(info.argumentType, instanceOf([TypeInfo class]));
	}];
}

#pragma mark - beginMethodArgumentTypes

- (void)testBeginMethodArgumentTypesShouldCreateNewTypeInfo {
	[self runWithMethodArgumentInfo:^(MethodArgumentInfo *info) {
		// setup
		id mock = [OCMockObject mockForClass:[Store class]];
		[[mock expect] pushRegistrationObject:[OCMArg checkWithBlock:^BOOL(id obj) {
			return [obj isKindOfClass:[TypeInfo class]];
		}]];
		info.objectRegistrar = mock;
		// execute
		[info beginMethodArgumentTypes];
		// verify
		STAssertNoThrow([mock verify], nil);
	}];
}

#pragma mark - appendMethodArgumentSelector:

- (void)testAppendMethodArgumentSelectorShouldAssignGivenString {
	[self runWithMethodArgumentInfo:^(MethodArgumentInfo *info) {
		// execute
		[info appendMethodArgumentSelector:@"value"];
		// verify
		assertThat(info.argumentSelector, equalTo(@"value"));
	}];
}

- (void)testAppendMethodArgumentSelectorShouldUseLastValueIfSentMultipleTimes {
	[self runWithMethodArgumentInfo:^(MethodArgumentInfo *info) {
		// execute
		[info appendMethodArgumentSelector:@"value1"];
		[info appendMethodArgumentSelector:@"value2"];
		// verify
		assertThat(info.argumentSelector, equalTo(@"value2"));
	}];
}

#pragma mark - appendMethodArgumentVariable:

- (void)testAppendMethodArgumentVariableShouldAssignGivenString {
	[self runWithMethodArgumentInfo:^(MethodArgumentInfo *info) {
		// execute
		[info appendMethodArgumentVariable:@"value"];
		// verify
		assertThat(info.argumentVariable, equalTo(@"value"));
	}];
}

- (void)testAppendMethodArgumentVariableShouldUseLastValueIfSentMultipleTimes {
	[self runWithMethodArgumentInfo:^(MethodArgumentInfo *info) {
		// execute
		[info appendMethodArgumentVariable:@"value1"];
		[info appendMethodArgumentVariable:@"value2"];
		// verify
		assertThat(info.argumentVariable, equalTo(@"value2"));
	}];
}

@end

#pragma mark - 

@implementation MethodArgumentInfoTests (CreationMethods)

- (void)runWithMethodArgumentInfo:(void(^)(MethodArgumentInfo *info))handler {
	MethodArgumentInfo *info = [MethodArgumentInfo new];
	handler(info);
}

@end
