//
//  GBIvarDataTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 28.7.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBIvarData.h"

@interface GBIvarDataTesting : GHTestCase
@end

@implementation GBIvarDataTesting

- (void)testMergeDataFromObject_shouldMergeImplementationDetails {
	// setup - ivars don't merge any data, except they need to send base class merging message!
	GBIvarData *original = [GBTestObjectsRegistry ivarWithComponents:@"int", @"_name", nil];
	GBIvarData *source = [GBTestObjectsRegistry ivarWithComponents:@"int", @"_name", nil];
	[source registerDeclaredFile:@"file"];
	// execute
	[original mergeDataFromObject:source];
	// verify - simple testing here, fully tested in GBModelBaseTesting!
	assertThatInteger([original.declaredFiles count], equalToInteger(1));
}

- (void)testMergeDataFromObject_shouldThrowIfDifferentNameIfPassed {
	// setup
	GBIvarData *original = [GBTestObjectsRegistry ivarWithComponents:@"int", @"_name", nil];
	GBIvarData *source = [GBTestObjectsRegistry ivarWithComponents:@"int", @"_different", nil];
	// execute & verify
	GHAssertThrows([original mergeDataFromObject:source], nil);
}

- (void)testMergeDataFromObject_shouldThrowIfDifferentTypeIfPassed {
	// setup
	GBIvarData *original = [GBTestObjectsRegistry ivarWithComponents:@"NSString", @"*", @"_name", nil];
	GBIvarData *source = [GBTestObjectsRegistry ivarWithComponents:@"NSString", @"&", @"_name", nil];
	// execute & verify
	GHAssertThrows([original mergeDataFromObject:source], nil);
}

@end
