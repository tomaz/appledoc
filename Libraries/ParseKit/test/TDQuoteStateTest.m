//
//  PKQuoteStateTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/21/06.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDQuoteStateTest.h"


@implementation TDQuoteStateTest

- (void)setUp {
    quoteState = [[PKQuoteState alloc] init];
    r = [[PKReader alloc] init];
}


- (void)tearDown {
    [quoteState release];
    [r release];
}


- (void)testQuotedString {
    s = @"'stuff'";
    r.string = s;
    PKToken *tok = [quoteState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    TDEqualObjects(s, tok.stringValue);
    
}


- (void)testQuotedStringEOFTerminated {
    s = @"'stuff";
    r.string = s;
    PKToken *tok = [quoteState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    TDEqualObjects(s, tok.stringValue);
}


- (void)testQuotedStringRepairEOFTerminated {
    s = @"'stuff";
    r.string = s;
    quoteState.balancesEOFTerminatedQuotes = YES;
    PKToken *tok = [quoteState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    TDEqualObjects(@"'stuff'", tok.stringValue);
}


- (void)testQuotedStringPlus {
    s = @"'a quote here' more";
    r.string = s;
    PKToken *tok = [quoteState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    TDEqualObjects(@"'a quote here'", tok.stringValue);
}


- (void)test14CharQuotedString {
    s = @"'123456789abcef'";
    r.string = s;
    PKToken *tok = [quoteState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    TDEqualObjects(s, tok.stringValue);
    TDTrue(tok.isQuotedString);
}


- (void)test15CharQuotedString {
    s = @"'123456789abcefg'";
    r.string = s;
    PKToken *tok = [quoteState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    TDEqualObjects(s, tok.stringValue);
    TDTrue(tok.isQuotedString);
}


- (void)test16CharQuotedString {
    s = @"'123456789abcefgh'";
    r.string = s;
    PKToken *tok = [quoteState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    TDEqualObjects(s, tok.stringValue);
    TDTrue(tok.isQuotedString);
}


- (void)test31CharQuotedString {
    s = @"'123456789abcefgh123456789abcefg'";
    r.string = s;
    PKToken *tok = [quoteState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    TDEqualObjects(s, tok.stringValue);
    TDTrue(tok.isQuotedString);
}


- (void)test32CharQuotedString {
    s = @"'123456789abcefgh123456789abcefgh'";
    r.string = s;
    PKToken *tok = [quoteState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    TDEqualObjects(s, tok.stringValue);
    TDTrue(tok.isQuotedString);
}

@end
