//
//  GBCommentComponentsListTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 14.2.11.
//  Copyright (C) 2011 Gentle Bytes. All rights reserved.
//

#import "GBDataObjects.h"

@interface GBCommentComponentsListTesting : GHTestCase
@end
	
@implementation GBCommentComponentsListTesting

#pragma mark Initialization & disposal

- (void)testInit_shouldInitializeEmptyList {
	// setup & execute
	GBCommentComponentsList *list = [[GBCommentComponentsList alloc] init];
	// verify
	assertThat(list.components, isNot(nil));
	assertThatInteger([list.components count], equalToInteger(0));
}

#pragma mark Registration testing

- (void)testRegisterComponent_shouldAddComponentToComponentsArray {
	// setup
	GBCommentComponentsList *list = [[GBCommentComponentsList alloc] init];
	// execute
	[list registerComponent:[GBCommentComponent componentWithStringValue:@"a"]];
	// verify
	assertThatInteger([list.components count], equalToInteger(1));
	assertThat([[list.components objectAtIndex:0] stringValue], is(@"a"));
}

- (void)testRegisterComponent_shouldAddComponentsToArrayInOrder {
	// setup
	GBCommentComponentsList *list = [[GBCommentComponentsList alloc] init];
	// execute
	[list registerComponent:[GBCommentComponent componentWithStringValue:@"a"]];
	[list registerComponent:[GBCommentComponent componentWithStringValue:@"b"]];
	[list registerComponent:[GBCommentComponent componentWithStringValue:@"c"]];
	// verify
	assertThatInteger([list.components count], equalToInteger(3));
	assertThat([[list.components objectAtIndex:0] stringValue], is(@"a"));
	assertThat([[list.components objectAtIndex:1] stringValue], is(@"b"));
	assertThat([[list.components objectAtIndex:2] stringValue], is(@"c"));
}

@end
