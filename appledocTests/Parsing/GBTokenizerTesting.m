//
//  GBTokenizerTesting.m
//  appledocTests
//
//  Created by Jebeom Gyeong on 2/22/20.
//  Copyright © 2020 Gentle Bytes. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "GBApplicationSettingsProvider.h"
#import "GBTokenizer.h"
#import "GBTestObjectsRegistry.h"

@interface GBTokenizerTesting : XCTestCase

- (PKTokenizer *)defaultTokenizer;
- (PKTokenizer *)longTokenizer;
- (PKTokenizer *)commentsTokenizer;
- (PKTokenizer *)succesiveCommentsTokenizer;

@end

@implementation GBTokenizerTesting

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

#pragma mark Initialization testing

- (void)testInitWithTokenizer_shouldInitializeToFirstToken {
    // setup & execute
    GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[self defaultTokenizer] filename:@"file"];
    // verify
    XCTAssertEqualObjects([tokenizer.currentToken stringValue], @"one");
}

- (void)testInitWithTokenizer_shouldSkipOrdinaryComments {
    // setup & execute
    GBTokenizer *tokenizer1 = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"// comment\n bla"] filename:@"file"];
    GBTokenizer *tokenizer2 = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"/* comment */\n bla"] filename:@"file"];
    // verify
    XCTAssertEqualObjects([tokenizer1.currentToken stringValue], @"bla");
    XCTAssertEqualObjects([tokenizer2.currentToken stringValue], @"bla");
}

- (void)testInitWithTokenizer_shouldPositionOnFirstNonCommentToken {
    // setup & execute
    GBTokenizer *tokenizer1 = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"/// comment\n bla"] filename:@"file"];
    GBTokenizer *tokenizer2 = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"/** comment */\n bla"] filename:@"file"];
    // verify
    XCTAssertEqualObjects([tokenizer1.currentToken stringValue], @"bla");
    XCTAssertEqualObjects([tokenizer2.currentToken stringValue], @"bla");
}

- (void)testInitWithTokenizer_shouldSetupLastComment {
    // setup & execute
    GBTokenizer *tokenizer1 = (GBTokenizer *)[GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"/// comment\n bla"] filename:@"file"];
    GBTokenizer *tokenizer2 = (GBTokenizer *)[GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"/** comment */\n bla"] filename:@"file"];
    // verify
    XCTAssertEqualObjects([tokenizer1.lastComment stringValue], @"comment");
    XCTAssertEqualObjects([tokenizer2.lastComment stringValue], @"comment");
}

- (void)testInitWithTokenizer_shouldUseFullPathAsFilename {
    // setup & execute
    GBTokenizer *tokenizer1 = [GBTokenizer tokenizerWithSource:[self defaultTokenizer] filename:@"/Users/Path/to/filename.h"];
    GBTokenizer *tokenizer2 = [GBTokenizer tokenizerWithSource:[self defaultTokenizer] filename:@"filename.h"];
    // verify
    XCTAssertEqualObjects([tokenizer1 valueForKey:@"filename"], @"/Users/Path/to/filename.h");
    XCTAssertEqualObjects([tokenizer2 valueForKey:@"filename"], @"filename.h");
}

#pragma mark Lookahead testing

- (void)testLookahead_shouldReturnNextToken {
    // setup
    GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[self defaultTokenizer] filename:@"file"];
    // execute & verify
    XCTAssertEqualObjects([[tokenizer lookahead:0] stringValue], @"one");
    XCTAssertEqualObjects([[tokenizer lookahead:1] stringValue], @"two");
    XCTAssertEqualObjects([[tokenizer lookahead:2] stringValue], @"three");
}

- (void)testLookahead_shouldReturnEOFToken {
    // setup
    GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[self defaultTokenizer] filename:@"file"];
    // execute & verify
    XCTAssertEqualObjects([[tokenizer lookahead:3] stringValue], [[PKToken EOFToken] stringValue]);
    XCTAssertEqualObjects([[tokenizer lookahead:4] stringValue], [[PKToken EOFToken] stringValue]);
    XCTAssertEqualObjects([[tokenizer lookahead:999999999] stringValue], [[PKToken EOFToken] stringValue]);
}

- (void)testLookahead_shouldNotMovePosition {
    // setup
    GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[self defaultTokenizer] filename:@"file"];
    // execute & verify
    [tokenizer lookahead:1];
    XCTAssertEqualObjects([[tokenizer currentToken] stringValue], @"one");
    [tokenizer lookahead:2];
    XCTAssertEqualObjects([[tokenizer currentToken] stringValue], @"one");
    [tokenizer lookahead:3];
    XCTAssertEqualObjects([[tokenizer currentToken] stringValue], @"one");
    [tokenizer lookahead:99999];
    XCTAssertEqualObjects([[tokenizer currentToken] stringValue], @"one");
}

- (void)testLookahead_shouldSkipComments {
    // setup
    GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[self commentsTokenizer] filename:@"file"];
    // execute & verify
    XCTAssertEqualObjects([[tokenizer lookahead:0] stringValue], @"ONE");
    XCTAssertEqualObjects([[tokenizer lookahead:1] stringValue], @"TWO");
    XCTAssertEqualObjects([[tokenizer lookahead:2] stringValue], @"THREE");
    XCTAssertEqualObjects([[tokenizer lookahead:3] stringValue], @"FOUR");
    XCTAssertEqualObjects([[tokenizer lookahead:4] stringValue], [[PKToken EOFToken] stringValue]);
}

#pragma mark Consuming testing

- (void)testConsume_shouldMoveToNextToken {
    // setup
    GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[self defaultTokenizer] filename:@"file"];
    // execute & verify
    [tokenizer consume:1];
    XCTAssertEqualObjects([tokenizer.currentToken stringValue], @"two");
    [tokenizer consume:1];
    XCTAssertEqualObjects([tokenizer.currentToken stringValue], @"three");
}

- (void)testConsume_shouldReturnEOF {
    // setup
    GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[self defaultTokenizer] filename:@"file"];
    // execute
    [tokenizer consume:1];
    [tokenizer consume:1];
    [tokenizer consume:1];
    // verify
    XCTAssertEqualObjects([tokenizer.currentToken stringValue], [[PKToken EOFToken] stringValue]);
    XCTAssertTrue([tokenizer eof]);
}

- (void)testConsume_shouldSkipComments {
    // setup
    GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[self commentsTokenizer] filename:@"file"];
    // execute & verify - note that we initially position on the first token!
    [tokenizer consume:1];
    XCTAssertEqualObjects([[tokenizer currentToken] stringValue], @"TWO");
    [tokenizer consume:1];
    XCTAssertEqualObjects([[tokenizer currentToken] stringValue], @"THREE");
    [tokenizer consume:1];
    XCTAssertEqualObjects([[tokenizer currentToken] stringValue], @"FOUR");
}

- (void)testConsume_shouldSetLastComment {
    // setup
    GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[self commentsTokenizer] filename:@"file"];
    // execute & verify - note that we initially position on the first token!
    [tokenizer consume:1];
    XCTAssertEqualObjects([tokenizer.lastComment stringValue], @"second");
    [tokenizer consume:1];
    XCTAssertEqualObjects([tokenizer.lastComment stringValue], @"third");
    [tokenizer consume:1];
    XCTAssertNil([tokenizer.lastComment stringValue]);
}

- (void)testConsume_shouldSetPreviousComment {
    // setup
    GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[self succesiveCommentsTokenizer] filename:@"file"];
    // execute & verify - note that we initially position on the first token!
    [tokenizer consume:1];
    XCTAssertEqualObjects([tokenizer.previousComment stringValue], @"first\nfirst1");
    XCTAssertEqualObjects([tokenizer.lastComment stringValue], @"second");
    [tokenizer consume:1];
    XCTAssertEqualObjects([tokenizer.previousComment stringValue], @"second");
    XCTAssertEqualObjects([tokenizer.lastComment stringValue], @"third");
    [tokenizer consume:1];
    XCTAssertEqualObjects([tokenizer.previousComment stringValue], @"second");
    XCTAssertEqualObjects([tokenizer.lastComment stringValue], @"third");
}

- (void)testConsume_shouldSetProperCommentWhenConsumingMultipleTokens {
    // setup
    GBTokenizer *tokenizer1 = [GBTokenizer tokenizerWithSource:[self commentsTokenizer] filename:@"file"];
    GBTokenizer *tokenizer2 = [GBTokenizer tokenizerWithSource:[self commentsTokenizer] filename:@"file"];
    // execute & verify - note that we initially position on the first token!
    [tokenizer1 consume:2];
    XCTAssertEqualObjects([tokenizer1.lastComment stringValue], @"third");
    // execute & verify - note that we initially position on the first token!
    [tokenizer2 consume:3];
    XCTAssertNil([tokenizer2.lastComment stringValue]);
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
    XCTAssertEqual([tokens count], 4);
    XCTAssertEqualObjects(tokens[0], @"one");
    XCTAssertEqualObjects(tokens[1], @"two");
    XCTAssertEqualObjects(tokens[2], @"three");
    XCTAssertEqualObjects(tokens[3], @"four");
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
    XCTAssertEqual([tokens count], 3);
    XCTAssertEqualObjects(tokens[0], @"two");
    XCTAssertEqualObjects(tokens[1], @"three");
    XCTAssertEqualObjects(tokens[2], @"four");
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
    XCTAssertEqual(count, 0);
    XCTAssertEqualObjects([[tokenizer currentToken] stringValue], @"one");
}

- (void)testConsumeFromToUsingBlock_shouldConsumeEndToken {
    // setup
    GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[self longTokenizer] filename:@"file"];
    // execute
    [tokenizer consumeFrom:nil to:@"five" usingBlock:^(PKToken *token, BOOL *consume, BOOL *stop) {
    }];
    // verify
    XCTAssertEqualObjects([[tokenizer currentToken] stringValue], @"six");
}

- (void)testConsumeFromToUsingBlock_shouldAcceptNilBlock {
    // setup
    GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[self longTokenizer] filename:@"file"];
    // execute
    [tokenizer consumeFrom:nil to:@"five" usingBlock:nil];
    // verify
    XCTAssertEqualObjects([[tokenizer currentToken] stringValue], @"six");
}

- (void)testConsumeFromToUsingBlock_shouldQuitAndConsumeCurrentToken {
    // setup
    GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[self longTokenizer] filename:@"file"];
    // execute
    [tokenizer consumeFrom:nil to:@"five" usingBlock:^(PKToken *token, BOOL *consume, BOOL *stop) {
        *stop = YES;
    }];
    // verify
    XCTAssertEqualObjects([[tokenizer currentToken] stringValue], @"two");
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
    XCTAssertEqualObjects([[tokenizer currentToken] stringValue], @"one");
}

#pragma mark Comments parsing testing

- (void)testLastCommentString_shouldTrimSpacesFromBothEndsIfPrefixedWithSignleSpace {
    // setup & execute
    GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"/// comment     \n   ONE"] filename:@"file"];
    // verify
    XCTAssertEqualObjects([tokenizer.lastComment stringValue], @"comment");
}

- (void)testLastCommentString_shouldNotTrimSpacesIfPrefixedWithMultipleSpaces {
    // setup & execute
    GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"///  comment     \n   ONE"] filename:@"file"];
    // verify
    XCTAssertEqualObjects([tokenizer.lastComment stringValue], @"  comment     ");
}

- (void)testLastCommentString_shouldNotTrimSpacesIfPrefixedWithTab {
    // setup & execute
    GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"///\tcomment     \n   ONE"] filename:@"file"];
    // verify
    XCTAssertEqualObjects([tokenizer.lastComment stringValue], @"\tcomment     ");
}

- (void)testLastCommentString_shouldGroupSingleLineComments {
    // setup & execute
    GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"/// line1\n/// line2\n   ONE"] filename:@"file"];
    // verify
    XCTAssertEqualObjects([tokenizer.lastComment stringValue], @"line1\nline2");
}

- (void)testLastCommentString_shouldGroupSingleLineCommentsIfIndentationMatches {
    // setup & execute
    GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"    /// line1\n    /// line2\n   ONE"] filename:@"file"];
    // verify
    XCTAssertEqualObjects([tokenizer.lastComment stringValue], @"line1\nline2");
}

- (void)testLastCommentString_shouldIgnoreSingleLineCommentsIfIndentationDoesNotMatch {
    // setup & execute
    GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"    /// line1\n  /// line2\n   ONE"] filename:@"file"];
    // verify
    XCTAssertEqualObjects([tokenizer.lastComment stringValue], @"line2");
}

- (void)testLastCommentString_shouldIgnoreSingleLineCommentsIfEmptyLineFoundInBetween {
    // setup & execute
    GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"/// line1\n\n/// line2\n   ONE"] filename:@"file"];
    // verify
    XCTAssertEqualObjects([tokenizer.lastComment stringValue], @"line2");
}

- (void)testLastCommentString_shouldRemovePrefixLine {
    // setup & execute
    GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"/** -----------------\n line */\n   ONE"] filename:@"file"];
    // verify
    XCTAssertEqualObjects([tokenizer.lastComment stringValue], @"line");
}

- (void)testLastCommentString_shouldRemoveSuffixLine {
    // setup & execute
    GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"/** line\n ----------------- */\n   ONE"] filename:@"file"];
    // verify
    XCTAssertEqualObjects([tokenizer.lastComment stringValue], @"line");
}

- (void)testLastCommentString_shouldRemoveCommonPrefixInMultilineComments {
    GBTokenizer *tokenizer1 = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"/** first\n * second */ ONE"] filename:@"file"];
    GBTokenizer *tokenizer2 = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"/** \n * first\n * second */ ONE"] filename:@"file"];
    GBTokenizer *tokenizer3 = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"/** \n * first\n * second\n */ ONE"] filename:@"file"];
    // verify
    XCTAssertEqualObjects([tokenizer1.lastComment stringValue], @"first\nsecond");
    XCTAssertEqualObjects([tokenizer2.lastComment stringValue], @"\nfirst\nsecond");
    XCTAssertEqualObjects([tokenizer3.lastComment stringValue], @"\nfirst\nsecond\n");
}

- (void)testLastCommentString_shouldKeepCommonPrefixInSingleLineComments {
    GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"/// halo\n/// * first\n/// * second"] filename:@"file"];
    // verify
    XCTAssertEqualObjects([tokenizer.lastComment stringValue], @"halo\n* first\n* second");
}

- (void)testLastCommentString_shouldKeepExampleTabs {
    // setup & execute
    GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"/** line1\n\n\texample1\n\texample2\n\nline2 */\n   ONE"] filename:@"file"];
    // verify
    XCTAssertEqualObjects([tokenizer.lastComment stringValue], @"line1\n\n\texample1\n\texample2\n\nline2");
}

- (void)testLastCommentString_shouldDetectSingleLineCommentSourceInformation {
    // setup & execute
    GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"\n\n\n/// comment\nONE"] filename:@"file"];
    // verify
    XCTAssertEqualObjects([tokenizer.lastComment.sourceInfo filename], @"file");
    XCTAssertEqual([tokenizer.lastComment.sourceInfo lineNumber], 4);
}

- (void)testLastCommentString_shouldAssignSingleLineCommentLineNumberOfFirstLine {
    // setup & execute
    GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"/// line1\n/// line2\n/// line3\nONE"] filename:@"file"];
    // verify
    XCTAssertEqualObjects([tokenizer.lastComment.sourceInfo filename], @"file");
    XCTAssertEqual([tokenizer.lastComment.sourceInfo lineNumber], 1);
}

- (void)testLastCommentString_shouldDetectMultipleLineCommentSourceInformation {
    // setup & execute
    GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"\n\n\n/** comment */\nONE"] filename:@"file"];
    // verify
    XCTAssertEqualObjects([tokenizer.lastComment.sourceInfo filename], @"file");
    XCTAssertEqual([tokenizer.lastComment.sourceInfo lineNumber], 4);
}

- (void)testLastCommentString_shouldDetectPreviousAndLastCommentSourceInformation {
    // setup & execute
    GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"/// previous\n\n/** last */\nONE"] filename:@"file"];
    // verify
    XCTAssertEqual([tokenizer.previousComment.sourceInfo lineNumber], 1);
    XCTAssertEqual([tokenizer.lastComment.sourceInfo lineNumber], 3);
}

- (void)testLastCommentString_shouldDetectSectionNameAndAssignItToPreviousCommentWhenValidCommentFollows {
    // setup & execute
    GBApplicationSettingsProvider *settings = [GBTestObjectsRegistry realSettingsProvider];
    GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"/** previous */ /** @name name */ /** second */ ONE"] filename:@"file" settings:settings];
    // verify
    XCTAssertEqualObjects(tokenizer.previousComment.stringValue, @"@name name");
    XCTAssertEqualObjects(tokenizer.lastComment.stringValue, @"second");
}

- (void)testLastCommentString_shouldDetectSectionNameAndAssignItToPreviousCommentWhenInvalidCommentFollows {
    // setup & execute
    GBApplicationSettingsProvider *settings = [GBTestObjectsRegistry realSettingsProvider];
    GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"/** previous */ /** @name name */ /* second */ ONE"] filename:@"file" settings:settings];
    // verify
    XCTAssertEqualObjects(tokenizer.previousComment.stringValue, @"@name name");
    XCTAssertNil(tokenizer.lastComment);
}

- (void)testLastCommentString_shouldDetectSectionNameAndAssignItToPreviousCommentWhenNoOtherCommentFollows {
    // setup & execute
    GBApplicationSettingsProvider *settings = [GBTestObjectsRegistry realSettingsProvider];
    GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"/** previous */ /** @name name */ ONE"] filename:@"file" settings:settings];
    // verify
    XCTAssertEqualObjects(tokenizer.previousComment.stringValue, @"@name name");
    XCTAssertNil(tokenizer.lastComment);
}

- (void)testPostfixComment_shouldDetectSimplePostfixComment {
    // setup & execute
    GBApplicationSettingsProvider *settings = [GBTestObjectsRegistry realSettingsProvider];
    GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"typedef NS_ENUM(NSUInteger, e) {\nVALUE1,   ///< postfix1\nVALUE2 };"] filename:@"file" settings:settings];
    // verify
   [tokenizer consume:8];
   PKToken *startToken = tokenizer.currentToken;
   [tokenizer consume:6];
   XCTAssertEqualObjects([tokenizer postfixCommentFrom:startToken].stringValue, @"postfix1");
}

- (void)testPostfixComment_shouldDetectMultilinePostfixComment {
    // setup & execute
    GBApplicationSettingsProvider *settings = [GBTestObjectsRegistry realSettingsProvider];
    GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"typedef NS_ENUM(NSUInteger, e) {\nVALUE1,   ///< postfix1\n///< postfix2\nVALUE2 };"] filename:@"file" settings:settings];
    // verify
   [tokenizer consume:8];
   PKToken *startToken = tokenizer.currentToken;
   [tokenizer consume:7];
   XCTAssertEqualObjects([tokenizer postfixCommentFrom:startToken].stringValue, @"postfix1\npostfix2");
}

#pragma mark Miscellaneous methods

- (void)testResetComments_shouldResetCommentValues {
    // setup - remember that initializer already moves to first non-comment token!
    GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[PKTokenizer tokenizerWithString:@"/** comment1 */ /** comment2 */ ONE"] filename:@"file"];
    // execute
    [tokenizer resetComments];
    // verify
    XCTAssertNil(tokenizer.lastComment);
    XCTAssertNil(tokenizer.previousComment);
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
