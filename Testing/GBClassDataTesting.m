//
//  GBClassDataTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 28.7.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBDataObjects.h"

@interface GBClassDataTesting : GHTestCase
@end

@implementation GBClassDataTesting

#pragma mark Base data merging

- (void)testMergeDataFromObject_shouldMergeImplementationDetails {
	//setup
	GBClassData *original = [GBClassData classDataWithName:@"MyClass"];
	GBClassData *source = [GBClassData classDataWithName:@"MyClass"];
	[source registerSourceInfo:[GBSourceInfo infoWithFilename:@"file" lineNumber:1]];
	// execute
	[original mergeDataFromObject:source];
	// verify - simple testing here, fully tested in GBModelBaseTesting!
	assertThatInteger([original.sourceInfos count], equalToInteger(1));
}

#pragma mark Superclass data merging

- (void)testMergeDataFromObject_shouldMergeSuperclass {
	//setup
	GBClassData *original = [GBClassData classDataWithName:@"MyClass"];
	GBClassData *source = [GBClassData classDataWithName:@"MyClass"];
	source.nameOfSuperclass = @"NSObject";
	// execute
	[original mergeDataFromObject:source];
	// verify
	assertThat(original.nameOfSuperclass, is(@"NSObject"));
	assertThat(source.nameOfSuperclass, is(@"NSObject"));
}

- (void)testMergeDataFromObject_shouldPreserveSourceSuperclass {
	//setup
	GBClassData *original = [GBClassData classDataWithName:@"MyClass"];
	GBClassData *source = [GBClassData classDataWithName:@"MyClass"];
	source.nameOfSuperclass = @"NSObject";
	// execute
	[original mergeDataFromObject:source];
	// verify
	assertThat(source.nameOfSuperclass, is(@"NSObject"));
}

- (void)testMergeDataFromObject_shouldLeaveOriginalSuperclassIfDifferent {
	//setup
	GBClassData *original = [GBClassData classDataWithName:@"MyClass"];
	original.nameOfSuperclass = @"C1";
	GBClassData *source = [GBClassData classDataWithName:@"MyClass"];
	source.nameOfSuperclass = @"C2";
	// execute
	[original mergeDataFromObject:source];
	// verify
	assertThat(original.nameOfSuperclass, is(@"C1"));
	assertThat(source.nameOfSuperclass, is(@"C2"));
}

#pragma mark Components merging

- (void)testMergeDataFromObject_shouldMergeAdoptedProtocolsAndPreserveSourceData {
	//setup - only basic handling is done here; details are tested within GBAdoptedProtocolsProviderTesting!
	GBClassData *original = [GBClassData classDataWithName:@"MyClass"];
	[original.adoptedProtocols registerProtocol:[GBProtocolData protocolDataWithName:@"P1"]];
	[original.adoptedProtocols registerProtocol:[GBProtocolData protocolDataWithName:@"P2"]];
	GBClassData *source = [GBClassData classDataWithName:@"MyClass"];
	[source.adoptedProtocols registerProtocol:[GBProtocolData protocolDataWithName:@"P1"]];
	[source.adoptedProtocols registerProtocol:[GBProtocolData protocolDataWithName:@"P3"]];
	// execute
	[original mergeDataFromObject:source];
	// verify
	assertThatInteger([[original.adoptedProtocols protocols] count], equalToInteger(3));
	assertThatInteger([[source.adoptedProtocols protocols] count], equalToInteger(2));
}

- (void)testMergeDataFromObject_shouldMergeIvarsAndPreserveSourceData {
	//setup - only basic handling is done here; details are tested within GBIvarsProviderTesting!
	GBClassData *original = [GBClassData classDataWithName:@"MyClass"];
	[original.ivars registerIvar:[GBTestObjectsRegistry ivarWithComponents:@"int", @"_i1", nil]];
	[original.ivars registerIvar:[GBTestObjectsRegistry ivarWithComponents:@"int", @"_i2", nil]];
	GBClassData *source = [GBClassData classDataWithName:@"MyClass"];
	[source.ivars registerIvar:[GBTestObjectsRegistry ivarWithComponents:@"int", @"_i1", nil]];
	[source.ivars registerIvar:[GBTestObjectsRegistry ivarWithComponents:@"int", @"_i3", nil]];
	// execute
	[original mergeDataFromObject:source];
	// verify
	assertThatInteger([[original.ivars ivars] count], equalToInteger(3));
	assertThatInteger([[source.ivars ivars] count], equalToInteger(2));
}

- (void)testMergeDataFromObject_shouldMergeMethodsAndPreserveSourceData {
	//setup - only basic handling is done here; details are tested within GBIvarsProviderTesting!
	GBClassData *original = [GBClassData classDataWithName:@"MyClass"];
	[original.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m1", nil]];
	[original.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m2", nil]];
	GBClassData *source = [GBClassData classDataWithName:@"MyClass"];
	[source.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m1", nil]];
	[source.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m3", nil]];
	// execute
	[original mergeDataFromObject:source];
	// verify
	assertThatInteger([[original.methods methods] count], equalToInteger(3));
	assertThatInteger([[source.methods methods] count], equalToInteger(2));
}

#pragma mark Helper methods

- (void)testIsTopLevelObject_shouldReturnYES {
	// setup & execute
	GBClassData *class = [GBClassData classDataWithName:@"Class"];
	// verify
	assertThatBool(class.isTopLevelObject, equalToBool(YES));
}

@end
