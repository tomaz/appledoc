//
//  TypeInfoTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/18/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "TestCaseBase.h"

@interface TypeInfoTests : TestCaseBase
@end

@interface TypeInfoTests (CreationMethods)
- (void)runWithTypeInfo:(void(^)(TypeInfo *info))handler;
@end

@implementation TypeInfoTests

#pragma mark - appendType:

- (void)testAppendTypeShouldAddAllStringsToTypeItemsArray {
	[self runWithTypeInfo:^(TypeInfo *info) {
		// execute
		[info appendType:@"type1"];
		[info appendType:@"type2"];
		// verify
		assertThatInt(info.typeItems.count, equalToInt(2));
		assertThat([info.typeItems objectAtIndex:0], equalTo(@"type1"));
		assertThat([info.typeItems objectAtIndex:1], equalTo(@"type2"));
	}];
}

@end

#pragma mark - 

@implementation TypeInfoTests (CreationMethods)

- (void)runWithTypeInfo:(void(^)(TypeInfo *info))handler {
	TypeInfo *info = [TypeInfo new];
	handler(info);
}

@end
