//
//  GBAdoptedProtocolsProviderTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 26.7.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBTestObjectsRegistry.h"
#import "GBDataObjects.h"

@interface GBMethodDataTesting : SenTestCase
@end

@implementation GBMethodDataTesting

#pragma mark Initialization testing

- (void)testMethodData_shouldInitializeSingleTypelessInstanceSelector {
	// setup & execute
	GBMethodData *data = [GBTestObjectsRegistry instanceMethodWithArguments:[GBMethodArgument methodArgumentWithName:@"method"], nil];
	// verify
	assertThat(data.methodSelector, is(@"method"));
}

- (void)testMethodData_shouldInitializeSingleTypedInstanceSelector {
	// setup & execute
	GBMethodData *data = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
	// verify
	assertThat(data.methodSelector, is(@"method:"));
}

- (void)testMethodData_shouldInitializeMultipleArgumentInstanceSelector {
	// setup & execute
	GBMethodData *data = [GBTestObjectsRegistry instanceMethodWithNames:@"delegate", @"checked", @"something", nil];
	// verify
	assertThat(data.methodSelector, is(@"delegate:checked:something:"));
}

- (void)testMethodData_shouldInitializeSingleTypelessClassSelector {
	// setup & execute
	GBMethodData *data = [GBTestObjectsRegistry classMethodWithArguments:[GBMethodArgument methodArgumentWithName:@"method"], nil];
	// verify
	assertThat(data.methodSelector, is(@"method"));
}

- (void)testMethodData_shouldInitializeSingleTypedClassSelector {
	// setup & execute
	GBMethodData *data = [GBTestObjectsRegistry classMethodWithNames:@"method", nil];
	// verify
	assertThat(data.methodSelector, is(@"method:"));
}

- (void)testMethodData_shouldInitializeMultipleArgumentClassSelector {
	// setup & execute
	GBMethodData *data = [GBTestObjectsRegistry classMethodWithNames:@"delegate", @"checked", @"something", nil];
	// verify
	assertThat(data.methodSelector, is(@"delegate:checked:something:"));
}

- (void)testMethodData_shouldInitializePropertySelector {
	// setup & execute
	GBMethodData *data = [GBTestObjectsRegistry propertyMethodWithArgument:@"isSelected"];
	// verify
	assertThat(data.methodSelector, is(@"isSelected"));
}

#pragma mark Merging testing

- (void)testMergeDataFromObject_shouldMergeImplementationDetails {
	// setup - methods don't merge any data, except they need to send base class merging message!
	GBMethodData *original = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
	GBMethodData *source = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
	[source registerDeclaredFile:@"file"];
	// execute
	[original mergeDataFromObject:source];
	// verify - simple testing here, fully tested in GBModelBaseTesting!
	assertThatInteger([original.declaredFiles count], equalToInteger(1));
}

- (void)testMergeDataFromObject_shouldThrowIfDifferentTypeIfPassed {
	// setup
	GBMethodData *original = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
	GBMethodData *source = [GBTestObjectsRegistry classMethodWithNames:@"method", nil];
	// execute & verify
	STAssertThrows([original mergeDataFromObject:source], nil);
}

- (void)testMergeDataFromObject_shouldThrowIfDifferentSelectorIfPassed {
	// setup
	GBMethodData *original = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
	GBMethodData *source1 = [GBTestObjectsRegistry classMethodWithNames:@"someOtherMethod", nil];
	GBMethodData *source2 = [GBTestObjectsRegistry instanceMethodWithArguments:[GBMethodArgument methodArgumentWithName:@"method"], nil];
	// execute & verify
	STAssertThrows([original mergeDataFromObject:source1], nil); // different name alltogether
	STAssertThrows([original mergeDataFromObject:source2], nil); // same selector but difference in arguments
}

- (void)testMergeDataFromObject_shouldThrowIfDifferentResultIfPassed {
	// setup
	GBMethodData *original = [GBMethodData methodDataWithType:GBMethodTypeInstance result:[NSArray arrayWithObject:@"int"] arguments:[NSArray arrayWithObject:[GBMethodArgument methodArgumentWithName:@"method"]]];
	GBMethodData *source = [GBMethodData methodDataWithType:GBMethodTypeInstance result:[NSArray arrayWithObject:@"long"] arguments:[NSArray arrayWithObject:[GBMethodArgument methodArgumentWithName:@"method"]]];
	// execute & verify
	STAssertThrows([original mergeDataFromObject:source], nil);
}

@end
