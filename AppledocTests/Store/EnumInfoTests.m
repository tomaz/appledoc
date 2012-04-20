//
//  EnumInfoTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "TestCaseBase.h"

@interface EnumInfoTests : TestCaseBase
@end

@interface EnumInfoTests (CreationMethods)
- (void)runWithEnumInfo:(void(^)(EnumInfo *info))handler;
@end

@implementation EnumInfoTests

#pragma mark - Verify lazy initialization

- (void)testLazyInitializersWork {
	[self runWithEnumInfo:^(EnumInfo *info) {
		// execute & verify
		assertThat(info.enumItems, instanceOf([NSMutableArray class]));
	}];
}

#pragma mark - appendEnumerationItem:

- (void)testAppendEnumerationItemShouldAddAllItems {
	[self runWithEnumInfo:^(EnumInfo *info) {
		// execute
		[info appendEnumerationItem:@"item1"];
		[info appendEnumerationItem:@"item2"];
		// verify
		assertThatInt(info.enumItems.count, equalToInt(2));
		assertThat([info.enumItems objectAtIndex:0], instanceOf([EnumItemInfo class]));
		assertThat([info.enumItems objectAtIndex:1], instanceOf([EnumItemInfo class]));
		assertThat([[info.enumItems objectAtIndex:0] itemName], equalTo(@"item1"));
		assertThat([[info.enumItems objectAtIndex:1] itemName], equalTo(@"item2"));
	}];
}

#pragma mark - appendEnumerationValue:

- (void)testAppendEnumerationValueShouldAppendValueToOneAndOnlyItem {
	[self runWithEnumInfo:^(EnumInfo *info) {
		// setup
		[info appendEnumerationItem:@"item"];
		// execute
		[info appendEnumerationValue:@"value"];
		// verify
		assertThatInt(info.enumItems.count, equalToInt(1));
		assertThat([[info.enumItems objectAtIndex:0] itemName], equalTo(@"item"));
		assertThat([[info.enumItems objectAtIndex:0] itemValue], equalTo(@"value"));
	}];
}

- (void)testAppendEnumerationValueShouldAppendValueToLastItem {
	[self runWithEnumInfo:^(EnumInfo *info) {
		// setup
		[info appendEnumerationItem:@"item1"];
		[info appendEnumerationItem:@"item2"];
		// execute
		[info appendEnumerationValue:@"value"];
		// verify
		assertThatInt(info.enumItems.count, equalToInt(2));
		assertThat([[info.enumItems objectAtIndex:0] itemName], equalTo(@"item1"));
		assertThat([[info.enumItems objectAtIndex:0] itemValue], equalTo(nil));
		assertThat([[info.enumItems objectAtIndex:1] itemName], equalTo(@"item2"));
		assertThat([[info.enumItems objectAtIndex:1] itemValue], equalTo(@"value"));
	}];
}

- (void)testAppendEnumerationValueShouldIgnoreIfNoItemIsRegistered {
	[self runWithEnumInfo:^(EnumInfo *info) {
		// execute
		[info appendEnumerationValue:@"value"];
		// verify - we log a warning in such case, but we don't test it here!
		assertThatInt(info.enumItems.count, equalToInt(0));
	}];
}

@end

#pragma mark - 

@implementation EnumInfoTests (CreationMethods)

- (void)runWithEnumInfo:(void(^)(EnumInfo *info))handler {
	EnumInfo *info = [EnumInfo new];
	handler(info);
}

@end
