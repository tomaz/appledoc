//
//  GBMethodsProviderTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 26.7.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBTestObjectsRegistry.h"
#import "GBMethodsProvider.h"

@interface GBMethodsProviderTesting : SenTestCase
@end

@implementation GBMethodsProviderTesting

#pragma mark Method registration testing

- (void)testRegisterMethod_shouldAddMethodToList {
	// setup
	GBMethodsProvider *provider = [[GBMethodsProvider alloc] init];
	GBMethodData *method = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
	// execute
	[provider registerMethod:method];
	// verify
	assertThatInteger([provider.methods count], equalToInteger(1));
	assertThat([[provider.methods objectAtIndex:0] methodSelector], is(@"method:"));
}

- (void)testRegisterMethod_shouldIgnoreSameInstance {
	// setup
	GBMethodsProvider *provider = [[GBMethodsProvider alloc] init];
	GBMethodData *method = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
	// execute
	[provider registerMethod:method];
	// verify
	assertThatInteger([provider.methods count], equalToInteger(1));
}

- (void)testRegisterMethod_shouldMergeDifferentInstanceWithSameName {
	// setup
	GBMethodsProvider *provider = [[GBMethodsProvider alloc] init];
	GBMethodData *source = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
	OCMockObject *destination = [OCMockObject niceMockForClass:[GBMethodData class]];
	[[[destination stub] andReturn:@"method:"] methodSelector];
	[[destination expect] mergeDataFromObject:source];
	[provider registerMethod:(GBMethodData *)destination];
	// execute
	[provider registerMethod:source];
	// verify
	[destination verify];
}

#pragma mark Method merging testing

- (void)testMergeDataFromObjectsProvider_shouldMergeAllDifferentMethods {
	// setup
	GBMethodsProvider *original = [[GBMethodsProvider alloc] init];
	[original registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m1", nil]];
	[original registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m2", nil]];
	GBMethodsProvider *source = [[GBMethodsProvider alloc] init];
	[source registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m1", nil]];
	[source registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m3", nil]];
	// execute
	[original mergeDataFromMethodsProvider:source];
	// verify - only basic testing here, details at GBMethodDataTesting!
	NSArray *methods = [original methods];
	assertThatInteger([methods count], equalToInteger(3));
	assertThat([[methods objectAtIndex:0] methodSelector], is(@"m1:"));
	assertThat([[methods objectAtIndex:1] methodSelector], is(@"m2:"));
	assertThat([[methods objectAtIndex:2] methodSelector], is(@"m3:"));
}

- (void)testMergeDataFromObjectsProvider_shouldPreserveSourceData {
	// setup
	GBMethodsProvider *original = [[GBMethodsProvider alloc] init];
	[original registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m1", nil]];
	[original registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m2", nil]];
	GBMethodsProvider *source = [[GBMethodsProvider alloc] init];
	[source registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m1", nil]];
	[source registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m3", nil]];
	// execute
	[original mergeDataFromMethodsProvider:source];
	// verify - only basic testing here, details at GBMethodDataTesting!
	NSArray *methods = [source methods];
	assertThatInteger([methods count], equalToInteger(2));
	assertThat([[methods objectAtIndex:0] methodSelector], is(@"m1:"));
	assertThat([[methods objectAtIndex:1] methodSelector], is(@"m3:"));
}

@end
