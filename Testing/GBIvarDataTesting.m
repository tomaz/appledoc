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
	[source registerSourceInfo:[GBSourceInfo infoWithFilename:@"file" lineNumber:1]];
	// execute
	[original mergeDataFromObject:source];
	// verify - simple testing here, fully tested in GBModelBaseTesting!
	assertThatInteger([original.sourceInfos count], equalToInteger(1));
}

- (void)testIsTopLevelObject_shouldReturnNO {
	// setup & execute
	GBIvarData *ivar = [GBTestObjectsRegistry ivarWithComponents:@"int", @"_name", nil];
	// verify
	assertThatBool(ivar.isTopLevelObject, equalToBool(NO));
}

@end
