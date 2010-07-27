//
//  GBIvarsProviderTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 26.7.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBIvarsProvider.h"

@interface GBIvarsProviderTesting : SenTestCase
@end

@implementation GBIvarsProviderTesting

#pragma mark Ivar registration testing

- (void)testRegisterIvar_shouldAddIvarToList {
	// setup
	GBIvarsProvider *provider = [[GBIvarsProvider alloc] init];
	GBIvarData *ivar = [GBIvarData ivarDataWithComponents:[NSArray arrayWithObjects:@"NSUInteger", @"_name", nil]];
	// execute
	[provider registerIvar:ivar];
	// verify
	assertThatBool([provider.ivars containsObject:ivar], equalToBool(YES));
	assertThatInteger([provider.ivars count], equalToInteger(1));
	assertThat([provider.ivars objectAtIndex:0], is(ivar));
}

- (void)testRegisterIvar_shouldIgnoreSameInstance {
	// setup
	GBIvarsProvider *provider = [[GBIvarsProvider alloc] init];
	GBIvarData *ivar = [GBIvarData ivarDataWithComponents:[NSArray arrayWithObjects:@"NSUInteger", @"_name", nil]];
	// execute
	[provider registerIvar:ivar];
	[provider registerIvar:ivar];
	// verify
	assertThatInteger([provider.ivars count], equalToInteger(1));
}

- (void)testRegisterIvar_shouldPreventAddingDifferentInstanceWithSameName {
	// setup
	GBIvarsProvider *provider = [[GBIvarsProvider alloc] init];
	GBIvarData *ivar1 = [GBIvarData ivarDataWithComponents:[NSArray arrayWithObjects:@"NSUInteger", @"_name1", nil]];
	GBIvarData *ivar2 = [GBIvarData ivarDataWithComponents:[NSArray arrayWithObjects:@"NSRect", @"_name1", nil]];
	[provider registerIvar:ivar1];
	// execute & verify
	STAssertThrows([provider registerIvar:ivar2], nil);
}

@end
