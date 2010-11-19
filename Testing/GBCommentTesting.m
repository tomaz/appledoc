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

- (void)testHasParagraphs_shouldReturnProperValue {
	// setup
	GBComment *comment = [GBComment commentWithStringValue:@""];
	// execute & verify
	assertThatBool(comment.hasParagraphs, equalToBool(NO));
	[comment registerParagraph:[GBCommentParagraph paragraph]];
	assertThatBool(comment.hasParagraphs, equalToBool(YES));
}

- (void)testHasMultipleParagraphs_shouldReturnProperValue {
	// setup
	GBComment *comment = [GBComment commentWithStringValue:@""];
	// execute & verify
	assertThatBool(comment.hasMultipleParagraphs, equalToBool(NO));
	[comment registerParagraph:[GBCommentParagraph paragraph]];
	assertThatBool(comment.hasMultipleParagraphs, equalToBool(NO));
	[comment registerParagraph:[GBCommentParagraph paragraph]];
	assertThatBool(comment.hasMultipleParagraphs, equalToBool(YES));
}

#pragma mark Parameters testing

- (void)testRegisterParameter_shouldAddParameterToList {
	// setup
	GBComment *comment = [GBComment commentWithStringValue:@""];
	GBCommentArgument *parameter = [GBCommentArgument argumentWithName:@"name" description:[GBCommentParagraph paragraph]];
	// execute
	[comment registerParameter:parameter];
	// verify
	assertThatInteger([comment.parameters count], equalToInteger(1));
	assertThat([comment.parameters objectAtIndex:0], is(parameter));
}

- (void)testRegisterParagraph_shouldAddAllParametersToListInOrderRegistered {
	// setup
	GBComment *comment = [GBComment commentWithStringValue:@""];
	GBCommentArgument *parameter1 = [GBCommentArgument argumentWithName:@"name1" description:[GBCommentParagraph paragraph]];
	GBCommentArgument *parameter2 = [GBCommentArgument argumentWithName:@"name2" description:[GBCommentParagraph paragraph]];
	// execute
	[comment registerParameter:parameter1];
	[comment registerParameter:parameter2];
	// verify
	assertThatInteger([comment.parameters count], equalToInteger(2));
	assertThat([comment.parameters objectAtIndex:0], is(parameter1));
	assertThat([comment.parameters objectAtIndex:1], is(parameter2));
}

- (void)testRegisterParameter_shouldReplaceExistingParameter {
	// setup
	GBComment *comment = [GBComment commentWithStringValue:@""];
	GBCommentArgument *parameter1 = [GBCommentArgument argumentWithName:@"name" description:[GBCommentParagraph paragraph]];
	GBCommentArgument *parameter2 = [GBCommentArgument argumentWithName:@"name" description:[GBCommentParagraph paragraph]];
	// execute
	[comment registerParameter:parameter1];
	[comment registerParameter:parameter2];
	// verify
	assertThatInteger([comment.parameters count], equalToInteger(1));
	assertThat([comment.parameters objectAtIndex:0], is(parameter2));
}

- (void)testReplaceParametersWithParametersFromArray_shouldReplaceParameters {
	// setup
	GBComment *comment = [GBComment commentWithStringValue:@""];
	GBCommentArgument *parameter1 = [GBCommentArgument argumentWithName:@"name1" description:[GBCommentParagraph paragraph]];
	GBCommentArgument *parameter2 = [GBCommentArgument argumentWithName:@"name2" description:[GBCommentParagraph paragraph]];
	[comment registerParameter:parameter1];
	// execute
	[comment replaceParametersWithParametersFromArray:[NSArray arrayWithObjects:parameter2, parameter1, nil]];
	// verify
	assertThatInteger([comment.parameters count], equalToInteger(2));
	assertThat([comment.parameters objectAtIndex:0], is(parameter2));
	assertThat([comment.parameters objectAtIndex:1], is(parameter1));
}

- (void)testHasParameters_shouldReturnProperValue {
	// setup
	GBComment *comment = [GBComment commentWithStringValue:@""];
	// execute & verify
	assertThatBool(comment.hasParameters, equalToBool(NO));
	[comment registerParameter:[GBCommentArgument argumentWithName:@"name" description:[GBCommentParagraph paragraph]]];
	assertThatBool(comment.hasParameters, equalToBool(YES));
}

#pragma mark Exceptions testing

- (void)testRegisterException_shouldAddExceptionToList {
	// setup
	GBComment *comment = [GBComment commentWithStringValue:@""];
	GBCommentArgument *exception = [GBCommentArgument argumentWithName:@"name" description:[GBCommentParagraph paragraph]];
	// execute
	[comment registerException:exception];
	// verify
	assertThatInteger([comment.exceptions count], equalToInteger(1));
	assertThat([comment.exceptions objectAtIndex:0], is(exception));
}

- (void)testRegisterParagraph_shouldAddAllExceptionsToListInOrderRegistered {
	// setup
	GBComment *comment = [GBComment commentWithStringValue:@""];
	GBCommentArgument *exception1 = [GBCommentArgument argumentWithName:@"name1" description:[GBCommentParagraph paragraph]];
	GBCommentArgument *exception2 = [GBCommentArgument argumentWithName:@"name2" description:[GBCommentParagraph paragraph]];
	// execute
	[comment registerException:exception1];
	[comment registerException:exception2];
	// verify
	assertThatInteger([comment.exceptions count], equalToInteger(2));
	assertThat([comment.exceptions objectAtIndex:0], is(exception1));
	assertThat([comment.exceptions objectAtIndex:1], is(exception2));
}

- (void)testRegisterException_shouldReplaceExistingException {
	// setup
	GBComment *comment = [GBComment commentWithStringValue:@""];
	GBCommentArgument *exception1 = [GBCommentArgument argumentWithName:@"name" description:[GBCommentParagraph paragraph]];
	GBCommentArgument *exception2 = [GBCommentArgument argumentWithName:@"name" description:[GBCommentParagraph paragraph]];
	// execute
	[comment registerException:exception1];
	[comment registerException:exception2];
	// verify
	assertThatInteger([comment.exceptions count], equalToInteger(1));
	assertThat([comment.exceptions objectAtIndex:0], is(exception2));
}

#pragma mark CrossReferences testing

- (void)testRegisterCrossReference_shouldAddCrossReferenceToList {
	// setup
	GBComment *comment = [GBComment commentWithStringValue:@""];
	GBParagraphLinkItem *ref = [GBParagraphLinkItem paragraphItem];
	// execute
	[comment registerCrossReference:ref];
	// verify
	assertThatInteger([comment.crossrefs count], equalToInteger(1));
	assertThat([comment.crossrefs objectAtIndex:0], is(ref));
}

- (void)testRegisterParagraph_shouldAddAllCrossReferencesToListInOrderRegistered {
	// setup
	GBComment *comment = [GBComment commentWithStringValue:@""];
	GBParagraphLinkItem *ref1 = [GBParagraphLinkItem paragraphItemWithStringValue:@"link1"];
	GBParagraphLinkItem *ref2 = [GBParagraphLinkItem paragraphItemWithStringValue:@"link2"];
	// execute
	[comment registerCrossReference:ref1];
	[comment registerCrossReference:ref2];
	// verify
	assertThatInteger([comment.crossrefs count], equalToInteger(2));
	assertThat([comment.crossrefs objectAtIndex:0], is(ref1));
	assertThat([comment.crossrefs objectAtIndex:1], is(ref2));
}

- (void)testRegisterCrossReference_shouldReplaceExistingCrossReference {
	// setup
	GBComment *comment = [GBComment commentWithStringValue:@""];
	GBParagraphLinkItem *ref1 = [GBParagraphLinkItem paragraphItemWithStringValue:@"link"];
	GBParagraphLinkItem *ref2 = [GBParagraphLinkItem paragraphItemWithStringValue:@"link"];
	// execute
	[comment registerCrossReference:ref1];
	[comment registerCrossReference:ref2];
	// verify
	assertThatInteger([comment.crossrefs count], equalToInteger(1));
	assertThat([comment.crossrefs objectAtIndex:0], is(ref1));
}

@end
