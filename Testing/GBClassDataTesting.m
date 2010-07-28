//
//  GBClassDataTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 28.7.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBClassData.h"

@interface GBClassDataTesting : SenTestCase
@end

@implementation GBClassDataTesting

#pragma mark Superclass data merging

- (void)testMergeDataFromClass_shouldMergeSuperclass {
	//setup
	GBClassData *original = [GBClassData classDataWithName:@"MyClass"];
	GBClassData *source = [GBClassData classDataWithName:@"MyClass"];
	source.nameOfSuperclass = @"NSObject";
	// execute
	[original mergeDataFromClass:source];
	// verify
	assertThat(original.nameOfSuperclass, is(@"NSObject"));
	assertThat(source.nameOfSuperclass, is(@"NSObject"));
}

- (void)testMergeDataFromClass_shouldPreserveSourceSuperclass {
	//setup
	GBClassData *original = [GBClassData classDataWithName:@"MyClass"];
	GBClassData *source = [GBClassData classDataWithName:@"MyClass"];
	source.nameOfSuperclass = @"NSObject";
	// execute
	[original mergeDataFromClass:source];
	// verify
	assertThat(source.nameOfSuperclass, is(@"NSObject"));
}

- (void)testMergeDataFromClass_shouldLeaveOriginalSuperclassIfDifferent {
	//setup
	GBClassData *original = [GBClassData classDataWithName:@"MyClass"];
	original.nameOfSuperclass = @"C1";
	GBClassData *source = [GBClassData classDataWithName:@"MyClass"];
	source.nameOfSuperclass = @"C2";
	// execute
	[original mergeDataFromClass:source];
	// verify
	assertThat(original.nameOfSuperclass, is(@"C1"));
	assertThat(source.nameOfSuperclass, is(@"C2"));
}

@end
