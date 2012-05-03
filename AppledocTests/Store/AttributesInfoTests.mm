//
//  AttributesInfoTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/18/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "TestCaseBase.h"

@interface AttributesInfoTests : TestCaseBase
@end

@interface AttributesInfoTests (CreationMethods)
- (void)runWithPropertyAttributesInfo:(void(^)(AttributesInfo *info))handler;
@end

@implementation AttributesInfoTests

#pragma mark - Verify lazy initialization

- (void)testLazyInitializationShouldWork {
	[self runWithPropertyAttributesInfo:^(AttributesInfo *info) {
		// execute & verify
		assertThat(info.attributeItems, instanceOf([NSMutableArray class]));
	}];
}

#pragma mark - valueForAttribute:

- (void)testValueForAttributeShouldReturnValue {
	[self runWithPropertyAttributesInfo:^(AttributesInfo *info) {
		// setup
		info.attributeItems = [NSMutableArray arrayWithObjects:@"prefix", @"attribute", @"=", @"value", @"suffix", nil];
		// execute & verify
		assertThat([info valueForAttribute:@"attribute"], equalTo(@"value"));
	}];
}

- (void)testValueForAttributeShouldReturnCorrectValue {
	[self runWithPropertyAttributesInfo:^(AttributesInfo *info) {
		// setup
		info.attributeItems = [NSMutableArray arrayWithObjects:@"prefix", @"attribute1", @"=", @"value1", @"attribute2", @"=", @"value2", @"suffix", nil];
		// execute & verify
		assertThat([info valueForAttribute:@"attribute1"], equalTo(@"value1"));
		assertThat([info valueForAttribute:@"attribute2"], equalTo(@"value2"));
	}];
}

- (void)testValueForAttributeShouldReturnFirstAttributeValueIfMultipleAttributesWithSameNameArePresent {
	[self runWithPropertyAttributesInfo:^(AttributesInfo *info) {
		// setup
		info.attributeItems = [NSMutableArray arrayWithObjects:@"prefix", @"attribute", @"=", @"value1", @"attribute", @"=", @"value2", @"suffix", nil];
		// execute & verify
		assertThat([info valueForAttribute:@"attribute"], equalTo(@"value1"));
	}];
}

- (void)testValueForAttributeShouldReturnNilIfAttributeNotFound {
	[self runWithPropertyAttributesInfo:^(AttributesInfo *info) {
		// setup
		info.attributeItems = [NSMutableArray arrayWithObjects:@"prefix", @"attribute", @"=", @"value", @"suffix", nil];
		// execute & verify
		assertThat([info valueForAttribute:@"prefix"], equalTo(nil));
		assertThat([info valueForAttribute:@"suffix"], equalTo(nil));
		assertThat([info valueForAttribute:@"attr"], equalTo(nil));
		assertThat([info valueForAttribute:@"attribute1"], equalTo(nil));
		assertThat([info valueForAttribute:@"="], equalTo(nil));
		assertThat([info valueForAttribute:@"value"], equalTo(nil));
	}];
}

#pragma mark - appendAttribute:

- (void)testAppendAttributeShouldAddAllStringsToTypeItemsArray {
	[self runWithPropertyAttributesInfo:^(AttributesInfo *info) {
		// execute
		[info appendAttribute:@"type1"];
		[info appendAttribute:@"type2"];
		// verify
		assertThatInt(info.attributeItems.count, equalToInt(2));
		assertThat([info.attributeItems objectAtIndex:0], equalTo(@"type1"));
		assertThat([info.attributeItems objectAtIndex:1], equalTo(@"type2"));
	}];
}

@end

#pragma mark - 

@implementation AttributesInfoTests (CreationMethods)

- (void)runWithPropertyAttributesInfo:(void(^)(AttributesInfo *info))handler {
	AttributesInfo *info = [AttributesInfo new];
	handler(info);
}

@end
