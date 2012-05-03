//
//  StructInfoTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "TestCaseBase.h"

@interface StructInfoTests : TestCaseBase
@end

@interface StructInfoTests (CreationMethods)
- (void)runWithStructInfo:(void(^)(StructInfo *info))handler;
@end

@implementation StructInfoTests

#pragma mark - Verify lazy initialization

- (void)testLazyInitializersWork {
	[self runWithStructInfo:^(StructInfo *info) {
		// execute & verify
		assertThat(info.structItems, instanceOf([NSMutableArray class]));
	}];
}

#pragma mark - beginConstant

- (void)testBeginConstantShouldCreateNewConstantInfoAndPushItToRegistrationStack {
	[self runWithStructInfo:^(StructInfo *info) {
		// setup
		id mock = [OCMockObject mockForClass:[Store class]];
		[[mock expect] pushRegistrationObject:[OCMArg checkWithBlock:^BOOL(id obj) {
			return [obj isKindOfClass:[ConstantInfo class]];
		}]];
		info.objectRegistrar = mock;
		// execute
		[info beginConstant];
		// verify
		STAssertNoThrow([mock verify], nil);
		assertThatInt(info.structItems.count, equalToInt(1));
		assertThat(info.structItems.lastObject, instanceOf([ConstantInfo class]));
		assertThat([info.structItems.lastObject objectRegistrar], equalTo(mock));
	}];
}

#pragma mark - cancelCurrentObject

- (void)testCancelCurrentObjectShouldRemoveConstantInfo {
	[self runWithStructInfo:^(StructInfo *info) {
		// setup
		[info beginConstant];
		id mock = [OCMockObject niceMockForClass:[Store class]];
		[[[mock stub] andReturn:info.structItems.lastObject] currentRegistrationObject];
		info.objectRegistrar = mock;
		// execute
		[info cancelCurrentObject];
		// verify
		assertThatInt(info.structItems.count, equalToInt(0));
	}];
}

@end

#pragma mark - 

@implementation StructInfoTests (CreationMethods)

- (void)runWithStructInfo:(void(^)(StructInfo *info))handler {
	StructInfo *info = [StructInfo new];
	handler(info);
}

@end
