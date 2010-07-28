//
//  GBModelBaseTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 28.7.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBModelBase.h"

@interface GBModelBaseTesting : SenTestCase
@end

@implementation GBModelBaseTesting

- (void)testMergeDataFromObject_shouldMergeImplementationDetails {
	// setup
	GBModelBase *original = [[GBModelBase alloc] init];
	[original registerDeclaredFile:@"f1"];
	[original registerDeclaredFile:@"f2"];
	GBModelBase *source = [[GBModelBase alloc] init];
	[source registerDeclaredFile:@"f1"];
	[source registerDeclaredFile:@"f3"];
	// execute
	[original mergeDataFromObject:source];
	// verify
	NSArray *files = [original declaredFilesSortedByName];
	assertThatInteger([files count], equalToInteger(3));
	assertThat([files objectAtIndex:0], is(@"f1"));
	assertThat([files objectAtIndex:1], is(@"f2"));
	assertThat([files objectAtIndex:2], is(@"f3"));
}

- (void)testMergeDataFromObject_shouldPreserveSourceImplementationDetails {
	// setup
	GBModelBase *original = [[GBModelBase alloc] init];
	[original registerDeclaredFile:@"f1"];
	[original registerDeclaredFile:@"f2"];
	GBModelBase *source = [[GBModelBase alloc] init];
	[source registerDeclaredFile:@"f1"];
	[source registerDeclaredFile:@"f3"];
	// execute
	[original mergeDataFromObject:source];
	// verify
	NSArray *files = [source declaredFilesSortedByName];
	assertThatInteger([files count], equalToInteger(2));
	assertThat([files objectAtIndex:0], is(@"f1"));
	assertThat([files objectAtIndex:1], is(@"f3"));
}

@end
