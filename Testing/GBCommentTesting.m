//
//  GBCommentTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 25.7.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBComment.h"
#import "GBCommentParagraph.h"

@interface GBCommentTesting : GHTestCase
@end
	
@implementation GBCommentTesting

#pragma mark Paragraphs testing

- (void)testRegisterParagraph_shouldAddParagraphToList {
	// setup
	GBComment *comment = [GBComment commentWithStringValue:@""];
	GBCommentParagraph *paragraph = [GBCommentParagraph paragraph];
	// execute
	[comment registerParagraph:paragraph];
	// verify
	assertThatInteger([comment.paragraphs count], equalToInteger(1));
	assertThat([comment.paragraphs objectAtIndex:0], is(paragraph));
}

- (void)testRegisterParagraph_shouldAddAllParagraphsToListInOrderRegistered {
	// setup
	GBComment *comment = [GBComment commentWithStringValue:@""];
	GBCommentParagraph *paragraph1 = [GBCommentParagraph paragraph];
	GBCommentParagraph *paragraph2 = [GBCommentParagraph paragraph];
	// execute
	[comment registerParagraph:paragraph1];
	[comment registerParagraph:paragraph2];
	// verify
	assertThatInteger([comment.paragraphs count], equalToInteger(2));
	assertThat([comment.paragraphs objectAtIndex:0], is(paragraph1));
	assertThat([comment.paragraphs objectAtIndex:1], is(paragraph2));
}

- (void)testRegisterParagraph_shouldSetParagraphAsFirstParagraph {
	// setup
	GBComment *comment = [GBComment commentWithStringValue:@""];
	GBCommentParagraph *paragraph = [GBCommentParagraph paragraph];
	// execute
	[comment registerParagraph:paragraph];
	// verify
	assertThat(comment.firstParagraph, is(paragraph));
}

- (void)testRegisterParagraph_shouldSetFirstParagraphOnlyOnce {
	// setup
	GBComment *comment = [GBComment commentWithStringValue:@""];
	GBCommentParagraph *paragraph1 = [GBCommentParagraph paragraph];
	GBCommentParagraph *paragraph2 = [GBCommentParagraph paragraph];
	// execute
	[comment registerParagraph:paragraph1];
	[comment registerParagraph:paragraph2];
	// verify
	assertThat(comment.firstParagraph, is(paragraph1));
}

#pragma mark Parameters testing

- (void)testRegisterParameter_shouldAddParameterToList {
	// setup
	GBComment *comment = [GBComment commentWithStringValue:@""];
	GBCommentArgument *parameter = [GBCommentArgument argument];
	// execute
	[comment registerParameter:parameter];
	// verify
	assertThatInteger([comment.parameters count], equalToInteger(1));
	assertThat([comment.parameters objectAtIndex:0], is(parameter));
}

- (void)testRegisterParagraph_shouldAddAllParametersToListInOrderRegistered {
	// setup
	GBComment *comment = [GBComment commentWithStringValue:@""];
	GBCommentArgument *parameter1 = [GBCommentArgument argument];
	GBCommentArgument *parameter2 = [GBCommentArgument argument];
	// execute
	[comment registerParameter:parameter1];
	[comment registerParameter:parameter2];
	// verify
	assertThatInteger([comment.parameters count], equalToInteger(2));
	assertThat([comment.parameters objectAtIndex:0], is(parameter1));
	assertThat([comment.parameters objectAtIndex:1], is(parameter2));
}

@end
