//
//  GBCommentTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 25.7.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBDataObjects.h"

@interface GBCommentTesting : GHTestCase
@end
	
@implementation GBCommentTesting

#pragma mark Initialization & disposal

- (void)testInit_shouldSetupDefaultComponents {
	// setup & execute
	GBComment *comment = [GBComment commentWithStringValue:@""];
	// verify
	assertThat(comment.longDescription, isNot(nil));
	assertThat(comment.methodParameters, isNot(nil));
	assertThat(comment.methodExceptions, isNot(nil));
	assertThat(comment.methodResult, isNot(nil));
}

@end
