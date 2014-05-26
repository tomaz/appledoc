//
//  GBTokenizerTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 26.7.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBApplicationSettingsProvider.h"
#import "GBTokenizer.h"

@interface GBTokenizerTesting : GHTestCase

- (PKTokenizer *)defaultTokenizer;
- (PKTokenizer *)longTokenizer;
- (PKTokenizer *)commentsTokenizer;
- (PKTokenizer *)succesiveCommentsTokenizer;

@end

@implementation GBTokenizerTesting

#pragma mark Initialization testing

- (void)testInitWithTokenizer_shouldInitializeToFirstToken {
	// setup & execute
	GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[self defaultTokenizer] filename:@"file"];
	// verify
	assertThat([tokenizer.currentToken stringValue], is(@"one"));
}

- (void)testInitWithTokenizer_shouldSkipOrdinaryComments {
	// setup & execute
	GBTokenizer *tokenizer1 = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"// comment\n bla"] filename:@"file"];
	GBTokenizer *tokenizer2 = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"/* comment */\n bla"] filename:@"file"];
	// verify
	assertThat([tokenizer1.currentToken stringValue], is(@"bla"));
	assertThat([tokenizer2.currentToken stringValue], is(@"bla"));
}

- (void)testInitWithTokenizer_shouldPositionOnFirstNonCommentToken {
	// setup & execute
	GBTokenizer *tokenizer1 = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"/// comment\n bla"] filename:@"file"];
	GBTokenizer *tokenizer2 = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"/** comment */\n bla"] filename:@"file"];
	// verify
	assertThat([tokenizer1.currentToken stringValue], is(@"bla"));
	assertThat([tokenizer2.currentToken stringValue], is(@"bla"));
}

- (void)testInitWithTokenizer_shouldSetupLastComment {
	// setup & execute
	GBTokenizer *tokenizer1 = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"/// comment\n bla"] filename:@"file"];
	GBTokenizer *tokenizer2 = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"/** comment */\n bla"] filename:@"file"];
	// verify
	assertThat([tokenizer1.lastComment stringValue], is(@"comment"));
	assertThat([tokenizer2.lastComment stringValue], is(@"comment"));
}

- (void)testInitWithTokenizer_shouldUseFullPathAsFilename {
	// setup & execute
	GBTokenizer *tokenizer1 = [GBTokenizer tokenizerWithSource:[self defaultTokenizer] filename:@"/Users/Path/to/filename.h"];
	GBTokenizer *tokenizer2 = [GBTokenizer tokenizerWithSource:[self defaultTokenizer] filename:@"filename.h"];
	// verify
	assertThat([tokenizer1 valueForKey:@"filename"], is(@"/Users/Path/to/filename.h"));
	assertThat([tokenizer2 valueForKey:@"filename"], is(@"filename.h"));
}

#pragma mark Lookahead testing

- (void)testLookahead_shouldReturnNextToken {
	// setup
	GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[self defaultTokenizer] filename:@"file"];
	// execute & verify
	assertThat([[tokenizer lookahead:0] stringValue], is(@"one"));
	assertThat([[tokenizer lookahead:1] stringValue], is(@"two"));
	assertThat([[tokenizer lookahead:2] stringValue], is(@"three"));
}

- (void)testLookahead_shouldReturnEOFToken {
	// setup
	GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[self defaultTokenizer] filename:@"file"];
	// execute & verify
	assertThat([[tokenizer lookahead:3] stringValue], is([[PKToken EOFToken] stringValue]));
	assertThat([[tokenizer lookahead:4] stringValue], is([[PKToken EOFToken] stringValue]));
	assertThat([[tokenizer lookahead:999999999] stringValue], is([[PKToken EOFToken] stringValue]));
}

- (void)testLookahead_shouldNotMovePosition {
	// setup
	GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[self defaultTokenizer] filename:@"file"];
	// execute & verify
	[tokenizer lookahead:1];
	assertThat([[tokenizer currentToken] stringValue], is(@"one"));
	[tokenizer lookahead:2];
	assertThat([[tokenizer currentToken] stringValue], is(@"one"));
	[tokenizer lookahead:3];
	assertThat([[tokenizer currentToken] stringValue], is(@"one"));
	[tokenizer lookahead:99999];
	assertThat([[tokenizer currentToken] stringValue], is(@"one"));
}

- (void)testLookahead_shouldSkipComments {
	// setup
	GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[self commentsTokenizer] filename:@"file"];
	// execute & verify
	assertThat([[tokenizer lookahead:0] stringValue], is(@"ONE"));
	assertThat([[tokenizer lookahead:1] stringValue], is(@"TWO"));
	assertThat([[tokenizer lookahead:2] stringValue], is(@"THREE"));
	assertThat([[tokenizer lookahead:3] stringValue], is(@"FOUR"));
	assertThat([[tokenizer lookahead:4] stringValue], is([[PKToken EOFToken] stringValue]));
}

#pragma mark Consuming testing

- (void)testConsume_shouldMoveToNextToken {
	// setup
	GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[self defaultTokenizer] filename:@"file"];
	// execute & verify
	[tokenizer consume:1];
	assertThat([tokenizer.currentToken stringValue], is(@"two"));
	[tokenizer consume:1];
	assertThat([tokenizer.currentToken stringValue], is(@"three"));
}

- (void)testConsume_shouldReturnEOF {
	// setup
	GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[self defaultTokenizer] filename:@"file"];
	// execute
	[tokenizer consume:1];
	[tokenizer consume:1];
	[tokenizer consume:1];
	// verify
	assertThat([tokenizer.currentToken stringValue], equalTo([[PKToken EOFToken] stringValue]));
	assertThatBool([tokenizer eof], equalToBool(YES));
}

- (void)testConsume_shouldSkipComments {
	// setup
	GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[self commentsTokenizer] filename:@"file"];
	// execute & verify - note that we initially position on the first token!
	[tokenizer consume:1];
	assertThat([[tokenizer currentToken] stringValue], is(@"TWO"));
	[tokenizer consume:1];
	assertThat([[tokenizer currentToken] stringValue], is(@"THREE"));
	[tokenizer consume:1];
	assertThat([[tokenizer currentToken] stringValue], is(@"FOUR"));
}

- (void)testConsume_shouldSetLastComment {
	// setup
	GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[self commentsTokenizer] filename:@"file"];
	// execute & verify - note that we initially position on the first token!
	[tokenizer consume:1];
	assertThat([tokenizer.lastComment stringValue], is(@"second"));
	[tokenizer consume:1];
	assertThat([tokenizer.lastComment stringValue], is(@"third"));
	[tokenizer consume:1];
	assertThat([tokenizer.lastComment stringValue], is(nil));
}

- (void)testConsume_shouldSetPreviousComment {
	// setup
	GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[self succesiveCommentsTokenizer] filename:@"file"];
	// execute & verify - note that we initially position on the first token!
	[tokenizer consume:1];
	assertThat([tokenizer.previousComment stringValue], is(@"first\nfirst1"));
	assertThat([tokenizer.lastComment stringValue], is(@"second"));
	[tokenizer consume:1];
	assertThat([tokenizer.previousComment stringValue], is(@"second"));
	assertThat([tokenizer.lastComment stringValue], is(@"third"));
	[tokenizer consume:1];
	assertThat([tokenizer.previousComment stringValue], is(@"second"));
	assertThat([tokenizer.lastComment stringValue], is(@"third"));
}

- (void)testConsume_shouldSetProperCommentWhenConsumingMultipleTokens {
	// setup
	GBTokenizer *tokenizer1 = [GBTokenizer tokenizerWithSource:[self commentsTokenizer] filename:@"file"];
	GBTokenizer *tokenizer2 = [GBTokenizer tokenizerWithSource:[self commentsTokenizer] filename:@"file"];
	// execute & verify - note that we initially position on the first token!
	[tokenizer1 consume:2];
	assertThat([tokenizer1.lastComment stringValue], is(@"third"));
	// execute & verify - note that we initially position on the first token!
	[tokenizer2 consume:3];
	assertThat([tokenizer2.lastComment stringValue], is(nil));
}

#pragma mark Block consuming testing

- (void)testConsumeFromToUsingBlock_shouldReportAllTokens {
	// setup
	GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[self longTokenizer] filename:@"file"];
	NSMutableArray *tokens = [NSMutableArray array];
	// execute
	[tokenizer consumeFrom:nil to:@"five" usingBlock:^(PKToken *token, BOOL *consume, BOOL *stop) {
		[tokens addObject:[token stringValue]];
	}];
	// verify
	assertThatInteger([tokens count], equalToInteger(4));
	assertThat([tokens objectAtIndex:0], is(@"one"));
	assertThat([tokens objectAtIndex:1], is(@"two"));
	assertThat([tokens objectAtIndex:2], is(@"three"));
	assertThat([tokens objectAtIndex:3], is(@"four"));
}

- (void)testConsumeFromToUsingBlock_shouldReportAllTokensFromTo {
	// setup
	GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[self longTokenizer] filename:@"file"];
	NSMutableArray *tokens = [NSMutableArray array];
	// execute
	[tokenizer consumeFrom:@"one" to:@"five" usingBlock:^(PKToken *token, BOOL *consume, BOOL *stop) {
		[tokens addObject:[token stringValue]];
	}];
	// verify
	assertThatInteger([tokens count], equalToInteger(3));
	assertThat([tokens objectAtIndex:0], is(@"two"));
	assertThat([tokens objectAtIndex:1], is(@"three"));
	assertThat([tokens objectAtIndex:2], is(@"four"));
}

- (void)testConsumeFromToUsingBlock_shouldReturnIfStartTokenDoesntMatch {
	// setup
	GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[self longTokenizer] filename:@"file"];
	__block NSUInteger count = 0;
	// execute
	[tokenizer consumeFrom:@"two" to:@"five" usingBlock:^(PKToken *token, BOOL *consume, BOOL *stop) {
		count++;
	}];
	// verify
	assertThatInteger(count, equalToInteger(0));
	assertThat([[tokenizer currentToken] stringValue], is(@"one"));
}

- (void)testConsumeFromToUsingBlock_shouldConsumeEndToken {
	// setup
	GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[self longTokenizer] filename:@"file"];
	// execute
	[tokenizer consumeFrom:nil to:@"five" usingBlock:^(PKToken *token, BOOL *consume, BOOL *stop) {
	}];
	// verify
	assertThat([[tokenizer currentToken] stringValue], is(@"six"));
}

- (void)testConsumeFromToUsingBlock_shouldAcceptNilBlock {
	// setup
	GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[self longTokenizer] filename:@"file"];
	// execute
	[tokenizer consumeFrom:nil to:@"five" usingBlock:nil];
	// verify
	assertThat([[tokenizer currentToken] stringValue], is(@"six"));
}

- (void)testConsumeFromToUsingBlock_shouldQuitAndConsumeCurrentToken {
	// setup
	GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[self longTokenizer] filename:@"file"];
	// execute
	[tokenizer consumeFrom:nil to:@"five" usingBlock:^(PKToken *token, BOOL *consume, BOOL *stop) {
		*stop = YES;
	}];
	// verify
	assertThat([[tokenizer currentToken] stringValue], is(@"two"));
}

- (void)testConsumeFromToUsingBlock_shouldQuitWithoutConsumingCurrentToken {
	// setup
	GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[self longTokenizer] filename:@"file"];
	// execute
	[tokenizer consumeFrom:nil to:@"five" usingBlock:^(PKToken *token, BOOL *consume, BOOL *stop) {
		*consume = NO;
		*stop = YES;
	}];
	// verify
	assertThat([[tokenizer currentToken] stringValue], is(@"one"));
}

#pragma mark Comments parsing testing

- (void)testLastCommentString_shouldTrimSpacesFromBothEndsIfPrefixedWithSignleSpace {
	// setup & execute
	GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"/// comment     \n   ONE"] filename:@"file"];
	// verify
	assertThat([tokenizer.lastComment stringValue], is(@"comment"));
}

- (void)testLastCommentString_shouldNotTrimSpacesIfPrefixedWithMultipleSpaces {
	// setup & execute
	GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"///  comment     \n   ONE"] filename:@"file"];
	// verify
	assertThat([tokenizer.lastComment stringValue], is(@"  comment     "));
}

- (void)testLastCommentString_shouldNotTrimSpacesIfPrefixedWithTab {
	// setup & execute
	GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"///\tcomment     \n   ONE"] filename:@"file"];
	// verify
	assertThat([tokenizer.lastComment stringValue], is(@"\tcomment     "));
}

- (void)testLastCommentString_shouldGroupSingleLineComments {
	// setup & execute
	GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"/// line1\n/// line2\n   ONE"] filename:@"file"];
	// verify
	assertThat([tokenizer.lastComment stringValue], is(@"line1\nline2"));
}

- (void)testLastCommentString_shouldGroupSingleLineCommentsIfIndentationMatches {
	// setup & execute
	GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"    /// line1\n    /// line2\n   ONE"] filename:@"file"];
	// verify
	assertThat([tokenizer.lastComment stringValue], is(@"line1\nline2"));
}

- (void)testLastCommentString_shouldIgnoreSingleLineCommentsIfIndentationDoesNotMatch {
	// setup & execute
	GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"    /// line1\n  /// line2\n   ONE"] filename:@"file"];
	// verify
	assertThat([tokenizer.lastComment stringValue], is(@"line2"));
}

- (void)testLastCommentString_shouldIgnoreSingleLineCommentsIfEmptyLineFoundInBetween {
	// setup & execute
	GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"/// line1\n\n/// line2\n   ONE"] filename:@"file"];
	// verify
	assertThat([tokenizer.lastComment stringValue], is(@"line2"));
}

- (void)testLastCommentString_shouldRemovePrefixLine {
	// setup & execute
	GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"/** -----------------\n line */\n   ONE"] filename:@"file"];
	// verify
	assertThat([tokenizer.lastComment stringValue], is(@"line"));
}

- (void)testLastCommentString_shouldRemoveSuffixLine {
	// setup & execute
	GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"/** line\n ----------------- */\n   ONE"] filename:@"file"];
	// verify
	assertThat([tokenizer.lastComment stringValue], is(@"line"));
}

- (void)testLastCommentString_shouldRemoveCommonPrefixInMultilineComments {
	GBTokenizer *tokenizer1 = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"/** first\n * second */ ONE"] filename:@"file"];
	GBTokenizer *tokenizer2 = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"/** \n * first\n * second */ ONE"] filename:@"file"];
	GBTokenizer *tokenizer3 = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"/** \n * first\n * second\n */ ONE"] filename:@"file"];
	// verify
	assertThat([tokenizer1.lastComment stringValue], is(@"first\nsecond"));
	assertThat([tokenizer2.lastComment stringValue], is(@"\nfirst\nsecond"));
	assertThat([tokenizer3.lastComment stringValue], is(@"\nfirst\nsecond\n"));
}

- (void)testLastCommentString_shouldKeepCommonPrefixInSingleLineComments {
	GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"/// halo\n/// * first\n/// * second"] filename:@"file"];
	// verify
	assertThat([tokenizer.lastComment stringValue], is(@"halo\n* first\n* second"));
}

- (void)testLastCommentString_shouldKeepExampleTabs {
	// setup & execute
	GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"/** line1\n\n\texample1\n\texample2\n\nline2 */\n   ONE"] filename:@"file"];
	// verify
	assertThat([tokenizer.lastComment stringValue], is(@"line1\n\n\texample1\n\texample2\n\nline2"));
}

- (void)testLastCommentString_shouldDetectSingleLineCommentSourceInformation {
	// setup & execute
	GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"\n\n\n/// comment\nONE"] filename:@"file"];
	// verify
	assertThat([tokenizer.lastComment.sourceInfo filename], is(@"file"));
	assertThatInteger([tokenizer.lastComment.sourceInfo lineNumber], equalToInteger(4));
}

- (void)testLastCommentString_shouldAssignSingleLineCommentLineNumberOfFirstLine {
	// setup & execute
	GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"/// line1\n/// line2\n/// line3\nONE"] filename:@"file"];
	// verify
	assertThat([tokenizer.lastComment.sourceInfo filename], is(@"file"));
	assertThatInteger([tokenizer.lastComment.sourceInfo lineNumber], equalToInteger(1));
}

- (void)testLastCommentString_shouldDetectMultipleLineCommentSourceInformation {
	// setup & execute
	GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"\n\n\n/** comment */\nONE"] filename:@"file"];
	// verify
	assertThat([tokenizer.lastComment.sourceInfo filename], is(@"file"));
	assertThatInteger([tokenizer.lastComment.sourceInfo lineNumber], equalToInteger(4));
}

- (void)testLastCommentString_shouldDetectPreviousAndLastCommentSourceInformation {
	// setup & execute
	GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"/// previous\n\n/** last */\nONE"] filename:@"file"];
	// verify
	assertThatInteger([tokenizer.previousComment.sourceInfo lineNumber], equalToInteger(1));
	assertThatInteger([tokenizer.lastComment.sourceInfo lineNumber], equalToInteger(3));
}

- (void)testLastCommentString_shouldDetectSectionNameAndAssignItToPreviousCommentWhenValidCommentFollows {
	// setup & execute
	GBApplicationSettingsProvider *settings = [GBTestObjectsRegistry realSettingsProvider];
	GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"/** previous */ /** @name name */ /** second */ ONE"] filename:@"file" settings:settings];
	// verify
	assertThat(tokenizer.previousComment.stringValue, is(@"@name name"));
	assertThat(tokenizer.lastComment.stringValue, is(@"second"));
}

- (void)testLastCommentString_shouldDetectSectionNameAndAssignItToPreviousCommentWhenInvalidCommentFollows {
	// setup & execute
	GBApplicationSettingsProvider *settings = [GBTestObjectsRegistry realSettingsProvider];
	GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"/** previous */ /** @name name */ /* second */ ONE"] filename:@"file" settings:settings];
	// verify
	assertThat(tokenizer.previousComment.stringValue, is(@"@name name"));
	assertThat(tokenizer.lastComment, is(nil));
}

- (void)testLastCommentString_shouldDetectSectionNameAndAssignItToPreviousCommentWhenNoOtherCommentFollows {
	// setup & execute
	GBApplicationSettingsProvider *settings = [GBTestObjectsRegistry realSettingsProvider];
	GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"/** previous */ /** @name name */ ONE"] filename:@"file" settings:settings];
	// verify
	assertThat(tokenizer.previousComment.stringValue, is(@"@name name"));
	assertThat(tokenizer.lastComment, is(nil));
}

- (void)testPostfixComment_shouldDetectSimplePostfixComment {
	// setup & execute
	GBApplicationSettingsProvider *settings = [GBTestObjectsRegistry realSettingsProvider];
	GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"typedef NS_ENUM(NSUInteger, e) {\nVALUE1,   ///< postfix1\nVALUE2 };"] filename:@"file" settings:settings];
	// verify
   [tokenizer consume:8];
   PKToken *startToken = tokenizer.currentToken;
   [tokenizer consume:6];
   assertThat([tokenizer postfixCommentFrom:startToken].stringValue, is(@"postfix1"));
}

- (void)testPostfixComment_shouldDetectMultilinePostfixComment {
	// setup & execute
	GBApplicationSettingsProvider *settings = [GBTestObjectsRegistry realSettingsProvider];
	GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"typedef NS_ENUM(NSUInteger, e) {\nVALUE1,   ///< postfix1\n///< postfix2\nVALUE2 };"] filename:@"file" settings:settings];
	// verify
   [tokenizer consume:8];
   PKToken *startToken = tokenizer.currentToken;
   [tokenizer consume:7];
   assertThat([tokenizer postfixCommentFrom:startToken].stringValue, is(@"postfix1\npostfix2"));
}

#pragma mark Miscellaneous methods

- (void)testResetComments_shouldResetCommentValues {
	// setup - remember that initializer already moves to first non-comment token!
	GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"/** comment1 */ /** comment2 */ ONE"] filename:@"file"];
	// execute
	[tokenizer resetComments];
	// verify
	assertThat(tokenizer.lastComment, is(nil));
	assertThat(tokenizer.previousComment, is(nil));
}

#pragma mark Creation methods

- (PKTokenizer *)defaultTokenizer {
	return [PKTokenizer tokenizerWithString:@"one two three"];
}

- (PKTokenizer *)longTokenizer {
	return [PKTokenizer tokenizerWithString:@"one two three four five six seven eight nine ten"];
}

- (PKTokenizer *)commentsTokenizer {
	return [PKTokenizer tokenizerWithString:@"/// first1\n/// first2\nONE\n/// second\nTWO\n///third\nTHREE /// -------------------\nFOUR"];
}

- (PKTokenizer *)succesiveCommentsTokenizer {
	return [PKTokenizer tokenizerWithString:@"ONE\n/// first\n/// first1\n\n/// second\nTWO\n/// third\nTHREE FOUR"];
}

@end
