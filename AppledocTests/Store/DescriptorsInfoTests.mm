//
//  DescriptorsInfoTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/18/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "TestCaseBase.h"

@interface DescriptorsInfoTests : TestCaseBase
@end

@interface DescriptorsInfoTests (CreationMethods)
- (void)runWithPropertyDescriptorsInfo:(void(^)(DescriptorsInfo *info))handler;
@end

@implementation DescriptorsInfoTests

#pragma mark - Verify lazy initialization

- (void)testLazyInitializationShouldWork {
	[self runWithPropertyDescriptorsInfo:^(DescriptorsInfo *info) {
		// execute & verify
		assertThat(info.descriptorItems, instanceOf([NSMutableArray class]));
	}];
}

#pragma mark - appendDescriptor:

- (void)testAppendDescriptorShouldAddAllStringsToTypeItemsArray {
	[self runWithPropertyDescriptorsInfo:^(DescriptorsInfo *info) {
		// execute
		[info appendDescriptor:@"type1"];
		[info appendDescriptor:@"type2"];
		// verify
		assertThatInt(info.descriptorItems.count, equalToInt(2));
		assertThat([info.descriptorItems objectAtIndex:0], equalTo(@"type1"));
		assertThat([info.descriptorItems objectAtIndex:1], equalTo(@"type2"));
	}];
}

@end

#pragma mark - 

@implementation DescriptorsInfoTests (CreationMethods)

- (void)runWithPropertyDescriptorsInfo:(void(^)(DescriptorsInfo *info))handler {
	DescriptorsInfo *info = [DescriptorsInfo new];
	handler(info);
}

@end
