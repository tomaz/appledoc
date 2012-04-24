//
//  ConstantInfoTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "TestCaseBase.h"

@interface ConstantInfoTests : TestCaseBase
@end

@interface ConstantInfoTests (CreationMethods)
- (void)runWithConstantInfo:(void(^)(ConstantInfo *info))handler;
@end

@implementation ConstantInfoTests

#pragma mark - Verify lazy initialization

- (void)testLazyInitializersWork {
	[self runWithConstantInfo:^(ConstantInfo *info) {
		// execute & verify
		assertThat(info.constantTypes, instanceOf([TypeInfo class]));
	}];
}


#pragma mark - beginConstantTypes

- (void)testBeginConstantTypesShouldChangeCurrentRegistrationObjectToTypes {
	[self runWithConstantInfo:^(ConstantInfo *info) {
		// setup
		id mock = [OCMockObject mockForClass:[Store class]];
		[[mock expect] pushRegistrationObject:[OCMArg checkWithBlock:^BOOL(id obj) {
			return [obj isKindOfClass:[TypeInfo class]];
		}]];
		info.objectRegistrar = mock;
		// execute
		[info beginConstantTypes];
		// verify
		STAssertNoThrow([mock verify], nil);
	}];
}

#pragma mark - appendConstantName:

- (void)testAppendConstantNameShouldAssignGivenString {
	[self runWithConstantInfo:^(ConstantInfo *info) {
		// execute
		[info appendConstantName:@"value"];
		// verify
		assertThat(info.constantName, equalTo(@"value"));
	}];
}

@end

#pragma mark - 

@implementation ConstantInfoTests (CreationMethods)

- (void)runWithConstantInfo:(void(^)(ConstantInfo *info))handler {
	ConstantInfo *info = [ConstantInfo new];
	handler(info);
}

@end
