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

#pragma mark Components merging

- (void)testMergeDataFromClass_shouldMergeAdoptedProtocolsAndPreserveSourceData {
	//setup - only basic handling is done here; details are tested within GBAdoptedProtocolsProviderTesting!
	GBClassData *original = [GBClassData classDataWithName:@"MyClass"];
	[original.adoptedProtocols registerProtocol:[GBProtocolData protocolDataWithName:@"P1"]];
	[original.adoptedProtocols registerProtocol:[GBProtocolData protocolDataWithName:@"P2"]];
	GBClassData *source = [GBClassData classDataWithName:@"MyClass"];
	[source.adoptedProtocols registerProtocol:[GBProtocolData protocolDataWithName:@"P1"]];
	[source.adoptedProtocols registerProtocol:[GBProtocolData protocolDataWithName:@"P3"]];
	// execute
	[original mergeDataFromClass:source];
	// verify
	assertThatInteger([[original.adoptedProtocols protocols] count], equalToInteger(3));
	assertThatInteger([[source.adoptedProtocols protocols] count], equalToInteger(2));
}

- (void)testMergeDataFromClass_shouldMergeIvarsAndPreserveSourceData {
	//setup - only basic handling is done here; details are tested within GBIvarsProviderTesting!
	GBClassData *original = [GBClassData classDataWithName:@"MyClass"];
	[original.ivars registerIvar:[GBTestObjectsRegistry ivarWithComponents:@"int", @"_i1", nil]];
	[original.ivars registerIvar:[GBTestObjectsRegistry ivarWithComponents:@"int", @"_i2", nil]];
	GBClassData *source = [GBClassData classDataWithName:@"MyClass"];
	[source.ivars registerIvar:[GBTestObjectsRegistry ivarWithComponents:@"int", @"_i1", nil]];
	[source.ivars registerIvar:[GBTestObjectsRegistry ivarWithComponents:@"int", @"_i3", nil]];
	// execute
	[original mergeDataFromClass:source];
	// verify
	assertThatInteger([[original.ivars ivars] count], equalToInteger(3));
	assertThatInteger([[source.ivars ivars] count], equalToInteger(2));
}

- (void)testMergeDataFromClass_shouldMergeMethodsAndPreserveSourceData {
	//setup - only basic handling is done here; details are tested within GBIvarsProviderTesting!
	GBClassData *original = [GBClassData classDataWithName:@"MyClass"];
	[original.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m1", nil]];
	[original.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m2", nil]];
	GBClassData *source = [GBClassData classDataWithName:@"MyClass"];
	[source.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m1", nil]];
	[source.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m3", nil]];
	// execute
	[original mergeDataFromClass:source];
	// verify
	assertThatInteger([[original.methods methods] count], equalToInteger(3));
	assertThatInteger([[source.methods methods] count], equalToInteger(2));
}

@end
