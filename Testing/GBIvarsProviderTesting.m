//
//  GBIvarsProviderTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 26.7.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBIvarsProvider.h"

@interface GBIvarsProviderTesting : GHTestCase
@end

@implementation GBIvarsProviderTesting

#pragma mark Ivar registration testing

- (void)testRegisterIvar_shouldAddIvarToList {
	// setup
	GBIvarsProvider *provider = [[GBIvarsProvider alloc] initWithParentObject:self];
	GBIvarData *ivar = [GBIvarData ivarDataWithComponents:[NSArray arrayWithObjects:@"NSUInteger", @"_name", nil]];
	// execute
	[provider registerIvar:ivar];
	// verify
	assertThatBool([provider.ivars containsObject:ivar], equalToBool(YES));
	assertThatInteger([provider.ivars count], equalToInteger(1));
	assertThat([provider.ivars objectAtIndex:0], is(ivar));
}

- (void)testRegisterIvar_shouldSetParentObject {
	// setup
	GBIvarsProvider *provider = [[GBIvarsProvider alloc] initWithParentObject:self];
	GBIvarData *ivar = [GBIvarData ivarDataWithComponents:[NSArray arrayWithObjects:@"NSUInteger", @"_name", nil]];
	// execute
	[provider registerIvar:ivar];
	// verify
	assertThat(ivar.parentObject, is(self));
}

- (void)testRegisterIvar_shouldIgnoreSameInstance {
	// setup
	GBIvarsProvider *provider = [[GBIvarsProvider alloc] initWithParentObject:self];
	GBIvarData *ivar = [GBIvarData ivarDataWithComponents:[NSArray arrayWithObjects:@"NSUInteger", @"_name", nil]];
	// execute
	[provider registerIvar:ivar];
	[provider registerIvar:ivar];
	// verify
	assertThatInteger([provider.ivars count], equalToInteger(1));
}

- (void)testRegisterIvar_shouldMergeDifferentInstanceWithSameName {
	// setup
	GBIvarsProvider *provider = [[GBIvarsProvider alloc] initWithParentObject:self];
	GBIvarData *source = [GBIvarData ivarDataWithComponents:[NSArray arrayWithObjects:@"int", @"_index", nil]];
	OCMockObject *destination = [OCMockObject niceMockForClass:[GBIvarData class]];
	[[[destination stub] andReturn:@"_index"] nameOfIvar];
	[[destination expect] mergeDataFromObject:source];
	[provider registerIvar:(GBIvarData *)destination];
	// execute
	[provider registerIvar:source];
	// verify
	[destination verify];
}

#pragma mark Merging testing

- (void)testMergeDataFromIvarsProvider_shouldMergeAllDifferentIvars {
	// setup
	GBIvarsProvider *original = [[GBIvarsProvider alloc] initWithParentObject:self];
	[original registerIvar:[GBTestObjectsRegistry ivarWithComponents:@"int", @"_i1", nil]];
	[original registerIvar:[GBTestObjectsRegistry ivarWithComponents:@"int", @"_i2", nil]];
	GBIvarsProvider *source = [[GBIvarsProvider alloc] initWithParentObject:self];
	[source registerIvar:[GBTestObjectsRegistry ivarWithComponents:@"int", @"_i1", nil]];
	[source registerIvar:[GBTestObjectsRegistry ivarWithComponents:@"int", @"_i3", nil]];
	// execute
	[original mergeDataFromIvarsProvider:source];
	// verify - only basic testing here, details at GBIvarDataTesting!
	NSArray *ivars = [original ivars];
	assertThatInteger([ivars count], equalToInteger(3));
	assertThat([[ivars objectAtIndex:0] nameOfIvar], is(@"_i1"));
	assertThat([[ivars objectAtIndex:1] nameOfIvar], is(@"_i2"));
	assertThat([[ivars objectAtIndex:2] nameOfIvar], is(@"_i3"));
}

- (void)testMergeDataFromIvarsProvider_shouldPreserveSourceData {
	// setup
	GBIvarsProvider *original = [[GBIvarsProvider alloc] initWithParentObject:self];
	[original registerIvar:[GBTestObjectsRegistry ivarWithComponents:@"int", @"_i1", nil]];
	[original registerIvar:[GBTestObjectsRegistry ivarWithComponents:@"int", @"_i2", nil]];
	GBIvarsProvider *source = [[GBIvarsProvider alloc] initWithParentObject:self];
	[source registerIvar:[GBTestObjectsRegistry ivarWithComponents:@"int", @"_i1", nil]];
	[source registerIvar:[GBTestObjectsRegistry ivarWithComponents:@"int", @"_i3", nil]];
	// execute
	[original mergeDataFromIvarsProvider:source];
	// verify - only basic testing here, details at GBIvarDataTesting!
	NSArray *ivars = [source ivars];
	assertThatInteger([ivars count], equalToInteger(2));
	assertThat([[ivars objectAtIndex:0] nameOfIvar], is(@"_i1"));
	assertThat([[ivars objectAtIndex:1] nameOfIvar], is(@"_i3"));
}

@end
