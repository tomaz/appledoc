//
//  GBIvarDataTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 28.7.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBIvarData.h"

@interface GBIvarDataTesting : SenTestCase
@end

@implementation GBIvarDataTesting

- (void)testMergeDataFromIvar_shouldMergeImplementationDetails {
	// setup
	GBIvarData *original = [GBTestObjectsRegistry ivarWithComponents:@"int", @"_name", nil];
	GBIvarData *source = [GBTestObjectsRegistry ivarWithComponents:@"int", @"_name", nil];
	// execute
	[original mergeDataFromIvar:source];
	// verify
	STFail(@"Implement source files for ivars!");
}

- (void)testMergeDataFromIvar_shouldPreserveSourceImplementationDetails {
	// setup
	GBIvarData *original = [GBTestObjectsRegistry ivarWithComponents:@"int", @"_name", nil];
	GBIvarData *source = [GBTestObjectsRegistry ivarWithComponents:@"int", @"_name", nil];
	// execute
	[original mergeDataFromIvar:source];
	// verify
	STFail(@"Implement source files for ivars!");
}

- (void)testMergeDataFromIvar_shouldThrowIfDifferentNameIfPassed {
	// setup
	GBIvarData *original = [GBTestObjectsRegistry ivarWithComponents:@"int", @"_name", nil];
	GBIvarData *source = [GBTestObjectsRegistry ivarWithComponents:@"int", @"_different", nil];
	// execute & verify
	STAssertThrows([original mergeDataFromIvar:source], nil);
}

- (void)testMergeDataFromIvar_shouldThrowIfDifferentTypeIfPassed {
	// setup
	GBIvarData *original = [GBTestObjectsRegistry ivarWithComponents:@"NSString", @"*", @"_name", nil];
	GBIvarData *source = [GBTestObjectsRegistry ivarWithComponents:@"NSString", @"&", @"_name", nil];
	// execute & verify
	STAssertThrows([original mergeDataFromIvar:source], nil);
}

@end
