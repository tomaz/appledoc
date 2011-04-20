//
//  PKCommentStateTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 12/28/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDCommentStateTest.h"

@implementation TDCommentStateTest

- (void)setUp {
    r = [[PKReader alloc] init];
    t = [[PKTokenizer alloc] init];
    commentState = t.commentState;
}


- (void)tearDown {
    [r release];
    [t release];
}


- (void)testSlashSlashFoo {
    s = @"// foo";
    r.string = s;
    t.string = s;
    tok = [commentState nextTokenFromReader:r startingWith:'/' tokenizer:t];
    TDEqualObjects(tok, [PKToken EOFToken]);
    TDEquals(tok.offset, (NSUInteger)-1);
    TDEquals([r read], PKEOF);
}


- (void)testReportSlashSlashFoo {
    s = @"// foo";
    r.string = s;
    t.string = s;
    commentState.reportsCommentTokens = YES;
    tok = [t nextToken];
    TDTrue(tok.isComment);
    TDEqualObjects(tok.stringValue, s);
    TDEquals(tok.offset, (NSUInteger)0);
    TDEqualObjects([t nextToken], [PKToken EOFToken]);
}


- (void)testReportSpaceSlashSlashFoo {
    s = @" // foo";
    r.string = s;
    t.string = s;
    commentState.reportsCommentTokens = YES;
    tok = [t nextToken];
    TDTrue(tok.isComment);
    TDEqualObjects(tok.stringValue, @"// foo");
    TDEquals(tok.offset, (NSUInteger)1);
    TDEqualObjects([t nextToken], [PKToken EOFToken]);
}


- (void)testTurnOffSlashSlashFoo {
    s = @"// foo";
    r.string = s;
    t.string = s;
    [commentState removeSingleLineStartMarker:@"//"];
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"/");
    TDEquals(tok.offset, (NSUInteger)0);
    TDEquals([r read], (PKUniChar)'/');
}


- (void)testHashFoo {
    s = @"# foo";
    r.string = s;
    t.string = s;
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"#");
    TDEquals(tok.offset, (NSUInteger)0);
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(tok.stringValue, @"foo");
    TDEquals(tok.offset, (NSUInteger)2);

    r.string = s;
    t.string = s;
    t.whitespaceState.reportsWhitespaceTokens = YES;
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"#");
    TDEquals(tok.offset, (NSUInteger)0);
    tok = [t nextToken];
    TDTrue(tok.isWhitespace);
    TDEqualObjects(tok.stringValue, @" ");
    TDEquals(tok.offset, (NSUInteger)1);
}


- (void)testAddHashFoo {
    s = @"# foo";
    t.string = s;
    [commentState addSingleLineStartMarker:@"#"];
    [t setTokenizerState:commentState from:'#' to:'#'];
    tok = [t nextToken];
    TDEquals(tok, [PKToken EOFToken]);
    TDEqualObjects(tok.stringValue, [[PKToken EOFToken] stringValue]);
    TDEquals(tok.offset, (NSUInteger)-1);
}


- (void)testReportAddHashFoo {
    s = @"# foo";
    t.string = s;
    commentState.reportsCommentTokens = YES;
    [commentState addSingleLineStartMarker:@"#"];
    [t setTokenizerState:commentState from:'#' to:'#'];
    tok = [t nextToken];
    TDTrue(tok.isComment);
    TDEqualObjects(tok.stringValue, s);
    TDEquals(tok.offset, (NSUInteger)0);
}


- (void)testSlashStarFooStarSlash {
    s = @"/* foo */";
    t.string = s;
    tok = [t nextToken];
    TDEqualObjects(tok, [PKToken EOFToken]);
    TDEquals([r read], PKEOF);
}


- (void)testSlashStarFooStarSlashSpace {
    s = @"/* foo */ ";
    t.string = s;
    tok = [t nextToken];
    TDEqualObjects(tok, [PKToken EOFToken]);
    TDEquals([r read], PKEOF);
}


- (void)testReportSlashStarFooStarSlash {
    s = @"/* foo */";
    r.string = s;
    t.string = s;
    commentState.reportsCommentTokens = YES;
    tok = [t nextToken];
    TDTrue(tok.isComment);
    TDEqualObjects(tok.stringValue, @"/* foo */");
    TDEquals([t nextToken], [PKToken EOFToken]);
    TDEquals(tok.offset, (NSUInteger)0);
}


- (void)testReportSlashStarFooStarSlashSpace {
    s = @"/* foo */ ";
    t.string = s;
    commentState.reportsCommentTokens = YES;
    tok = [t nextToken];
    TDTrue(tok.isComment);
    TDEqualObjects(tok.stringValue, @"/* foo */");
    TDEquals(tok.offset, (NSUInteger)0);
    tok = [t nextToken];
    TDEqualObjects(tok, [PKToken EOFToken]);

    t.string = s;
    commentState.reportsCommentTokens = YES;
    t.whitespaceState.reportsWhitespaceTokens = YES;
    tok = [t nextToken];
    TDTrue(tok.isComment);
    TDEquals(tok.offset, (NSUInteger)0);
    TDEqualObjects(tok.stringValue, @"/* foo */");
    tok = [t nextToken];
    TDTrue(tok.isWhitespace);
    TDEqualObjects(tok.stringValue, @" ");
}


- (void)testReportSlashStarFooStarSlashSpaceA {
    s = @"/* foo */ a";
    t.string = s;
    commentState.reportsCommentTokens = YES;
    tok = [t nextToken];
    TDTrue(tok.isComment);
    TDEqualObjects(tok.stringValue, @"/* foo */");
    TDEquals(tok.offset, (NSUInteger)0);
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(tok.stringValue, @"a");
    TDEquals(tok.offset, (NSUInteger)10);
    
    t.string = s;
    commentState.reportsCommentTokens = YES;
    t.whitespaceState.reportsWhitespaceTokens = YES;
    tok = [t nextToken];
    TDTrue(tok.isComment);
    TDEqualObjects(tok.stringValue, @"/* foo */");
    TDEquals(tok.offset, (NSUInteger)0);
    tok = [t nextToken];
    TDTrue(tok.isWhitespace);
    TDEqualObjects(tok.stringValue, @" ");
    TDEquals(tok.offset, (NSUInteger)9);
}


- (void)testReportSlashStarStarFooStarSlashSpaceA {
    s = @"/** foo */ a";
    t.string = s;
    commentState.reportsCommentTokens = YES;
    tok = [t nextToken];
    TDTrue(tok.isComment);
    TDEqualObjects(tok.stringValue, @"/** foo */");
    TDEquals(tok.offset, (NSUInteger)0);
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(tok.stringValue, @"a");
    TDEquals(tok.offset, (NSUInteger)11);
    
    t.string = s;
    commentState.reportsCommentTokens = YES;
    t.whitespaceState.reportsWhitespaceTokens = YES;
    tok = [t nextToken];
    TDTrue(tok.isComment);
    TDEqualObjects(tok.stringValue, @"/** foo */");
    TDEquals(tok.offset, (NSUInteger)0);
    tok = [t nextToken];
    TDTrue(tok.isWhitespace);
    TDEqualObjects(tok.stringValue, @" ");
    TDEquals(tok.offset, (NSUInteger)10);
}


- (void)testReportSlashStarFooStarStarSlashSpaceA {
    s = @"/* foo **/ a";
    t.string = s;
    commentState.reportsCommentTokens = YES;
    tok = [t nextToken];
    TDTrue(tok.isComment);
    TDEqualObjects(tok.stringValue, @"/* foo **/");
    TDEquals(tok.offset, (NSUInteger)0);
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(tok.stringValue, @"a");
    TDEquals(tok.offset, (NSUInteger)11);
    
    t.string = s;
    commentState.reportsCommentTokens = YES;
    t.whitespaceState.reportsWhitespaceTokens = YES;
    tok = [t nextToken];
    TDTrue(tok.isComment);
    TDEqualObjects(tok.stringValue, @"/* foo **/");
    TDEquals(tok.offset, (NSUInteger)0);
    tok = [t nextToken];
    TDTrue(tok.isWhitespace);
    TDEqualObjects(tok.stringValue, @" ");
    TDEquals(tok.offset, (NSUInteger)10);
}


- (void)testReportSlashStarFooStarSlashSpaceStarSlash {
    s = @"/* foo */ */";
    t.string = s;
    commentState.reportsCommentTokens = YES;
    tok = [t nextToken];
    TDTrue(tok.isComment);
    TDEqualObjects(tok.stringValue, @"/* foo */");
    TDEquals(tok.offset, (NSUInteger)0);
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"*");
    TDEquals(tok.offset, (NSUInteger)10);
    
    t.string = s;
    commentState.reportsCommentTokens = YES;
    t.whitespaceState.reportsWhitespaceTokens = YES;
    tok = [t nextToken];
    TDTrue(tok.isComment);
    TDEqualObjects(tok.stringValue, @"/* foo */");
    TDEquals(tok.offset, (NSUInteger)0);
    tok = [t nextToken];
    TDTrue(tok.isWhitespace);
    TDEqualObjects(tok.stringValue, @" ");
    TDEquals(tok.offset, (NSUInteger)9);
}


- (void)testTurnOffSlashStarFooStarSlash {
    s = @"/* foo */";
    t.string = s;
    [commentState removeMultiLineStartMarker:@"/*"];
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"/");
    TDEquals(tok.offset, (NSUInteger)0);
}


- (void)testReportSlashStarFooStar {
    s = @"/* foo *";
    t.string = s;
    commentState.reportsCommentTokens = YES;
    tok = [t nextToken];
    TDTrue(tok.isComment);
    TDEqualObjects(tok.stringValue, s);
    TDEquals(tok.offset, (NSUInteger)0);
}


- (void)testReportBalancedSlashStarFooStar {
    s = @"/* foo *";
    t.string = s;
    commentState.reportsCommentTokens = YES;
    commentState.balancesEOFTerminatedComments = YES;
    tok = [t nextToken];
    TDTrue(tok.isComment);
    TDEqualObjects(tok.stringValue, @"/* foo **/");
    TDEquals(tok.offset, (NSUInteger)0);
}


- (void)testReportBalancedSlashStarFoo {
    s = @"/* foo ";
    t.string = s;
    commentState.reportsCommentTokens = YES;
    commentState.balancesEOFTerminatedComments = YES;
    tok = [t nextToken];
    TDTrue(tok.isComment);
    TDEqualObjects(tok.stringValue, @"/* foo */");
    TDEquals(tok.offset, (NSUInteger)0);
}


- (void)testXMLFooStarXMLA {
    s = @"<!-- foo --> a";
    t.string = s;
    [commentState addMultiLineStartMarker:@"<!--" endMarker:@"-->"];
    [t setTokenizerState:commentState from:'<' to:'<'];
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(tok.stringValue, @"a");
    TDEquals(tok.offset, (NSUInteger)13);
    
    t.string = s;
    t.whitespaceState.reportsWhitespaceTokens = YES;
    tok = [t nextToken];
    TDTrue(tok.isWhitespace);
    TDEqualObjects(tok.stringValue, @" ");
    TDEquals(tok.offset, (NSUInteger)12);

    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(tok.stringValue, @"a");
    TDEquals(tok.offset, (NSUInteger)13);
}


- (void)testReportXMLFooStarXMLA {
    s = @"<!-- foo --> a";
    t.string = s;
    commentState.reportsCommentTokens = YES;
    [commentState addMultiLineStartMarker:@"<!--" endMarker:@"-->"];
    [t setTokenizerState:commentState from:'<' to:'<'];
    tok = [t nextToken];
    TDTrue(tok.isComment);
    TDEqualObjects(tok.stringValue, @"<!-- foo -->");
    TDEquals(tok.offset, (NSUInteger)0);
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(tok.stringValue, @"a");
    TDEquals(tok.offset, (NSUInteger)13);
    
    t.string = s;
    commentState.reportsCommentTokens = YES;
    t.whitespaceState.reportsWhitespaceTokens = YES;
    tok = [t nextToken];
    TDTrue(tok.isComment);
    TDEqualObjects(tok.stringValue, @"<!-- foo -->");
    TDEquals(tok.offset, (NSUInteger)0);
    tok = [t nextToken];
    TDTrue(tok.isWhitespace);
    TDEqualObjects(tok.stringValue, @" ");
    TDEquals(tok.offset, (NSUInteger)12);
}


- (void)testXXMarker {
    s = @"XX foo XX a";
    r.string = s;
    t.string = s;
    commentState.reportsCommentTokens = YES;
    [commentState addMultiLineStartMarker:@"XX" endMarker:@"XX"];
    [t setTokenizerState:commentState from:'X' to:'X'];
    tok = [t nextToken];
    TDTrue(tok.isComment);
    TDEqualObjects(tok.stringValue, @"XX foo XX");
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(tok.stringValue, @"a");
    
    r.string = s;
    t.string = s;
    commentState.reportsCommentTokens = YES;
    t.whitespaceState.reportsWhitespaceTokens = YES;
    tok = [t nextToken];
    TDTrue(tok.isComment);
    TDEqualObjects(tok.stringValue, @"XX foo XX");
    tok = [t nextToken];
    TDTrue(tok.isWhitespace);
    TDEqualObjects(tok.stringValue, @" ");
}


- (void)testXXMarkerFalseStartMarkerMatch {
    s = @"X foo X a";
    r.string = s;
    t.string = s;
    commentState.reportsCommentTokens = YES;
    [commentState addMultiLineStartMarker:@"XX" endMarker:@"XX"];
    [t setTokenizerState:commentState from:'X' to:'X'];
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(tok.stringValue, @"X");
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(tok.stringValue, @"foo");
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(tok.stringValue, @"X");
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(tok.stringValue, @"a");
    tok = [t nextToken];
    TDEqualObjects(tok, [PKToken EOFToken]);
}


- (void)testLuaComments {
    s = @"--[comment";
    t.string = s;
    
    [t setTokenizerState:t.symbolState from:'/' to:'/'];
    [t setTokenizerState:t.commentState from:'-' to:'-'];
    
    [t.commentState addSingleLineStartMarker:@"--"];
    [t.commentState addMultiLineStartMarker:@"--[[" endMarker:@"]]"];
    
    t.commentState.reportsCommentTokens = YES;
    
    PKToken *eof = [PKToken EOFToken];
    
    tok = [t nextToken];
    TDTrue(tok.isComment);
    TDEqualObjects(tok.stringValue, s);
    
    tok = [t nextToken];
    TDEquals(eof, tok);
}


- (void)testLuaComments2 {
    s = @"--[[[comment]]";
    t.string = s;
    
    [t setTokenizerState:t.symbolState from:'/' to:'/'];
    [t setTokenizerState:t.commentState from:'-' to:'-'];
    
    [t.commentState addSingleLineStartMarker:@"--"];
    [t.commentState addMultiLineStartMarker:@"--[[" endMarker:@"]]"];
    
    t.commentState.reportsCommentTokens = YES;
    
    PKToken *eof = [PKToken EOFToken];
    
    tok = [t nextToken];
    TDTrue(tok.isComment);
    TDEqualObjects(tok.stringValue, s);
    
    tok = [t nextToken];
    TDEquals(eof, tok);
}

@end
