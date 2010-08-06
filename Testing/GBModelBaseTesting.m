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

#pragma mark Common merging testing

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

- (void)testMergeDataFromObject_shouldRaiseExceptionOnDifferentClass {
	//setup
	GBIvarData *original = [GBTestObjectsRegistry ivarWithComponents:@"int", @"_name", nil];
	GBMethodData *source = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
	// execute & verify
	STAssertThrows([original mergeDataFromObject:source], nil);
}

#pragma mark Comments merging handling

- (void)testMergeDataFromObject_shouldUseOriginalCommentIfSourceIsNotGiven {
	// setup
	GBModelBase *original = [[GBModelBase alloc] init];
	[original registerCommentString:@"Comment"];
	GBModelBase *source = [[GBModelBase alloc] init];
	// execute
	[original mergeDataFromObject:source];
	// verify
	assertThat(original.commentString, is(@"Comment"));
	assertThat(source.commentString, is(nil));
}

- (void)testMergeDataFromObject_shouldUseSourceCommentIfOriginalIsNotGiven {
	// setup
	GBModelBase *original = [[GBModelBase alloc] init];
	GBModelBase *source = [[GBModelBase alloc] init];
	[source registerCommentString:@"Comment"];
	// execute
	[original mergeDataFromObject:source];
	// verify
	assertThat(original.commentString, is(@"Comment"));
	assertThat(source.commentString, is(@"Comment"));
}

- (void)testMergeDataFromObject_shouldKeepOriginalCommentIfBothObjectsHaveComments {
	// setup
	GBModelBase *original = [[GBModelBase alloc] init];
	[original registerCommentString:@"Comment1"];
	GBModelBase *source = [[GBModelBase alloc] init];
	[source registerCommentString:@"Comment2"];
	// execute
	[original mergeDataFromObject:source];
	// verify
	assertThat(original.commentString, is(@"Comment1"));
	assertThat(source.commentString, is(@"Comment2"));
}

@end
