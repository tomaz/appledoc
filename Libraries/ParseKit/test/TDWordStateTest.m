//
//  PKWordStateTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 6/7/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDWordStateTest.h"


@implementation TDWordStateTest

- (void)setUp {
    wordState = [[PKWordState alloc] init];
}


- (void)tearDown {
    [wordState release];
    [r release];
}


- (void)testA {
    s = @"a";
    r = [[PKReader alloc] initWithString:s];
    PKToken *tok = [wordState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    TDEqualObjects(@"a", tok.stringValue);
    TDEqualObjects(@"a", tok.value);
    TDTrue(tok.isWord);
    TDEquals(PKEOF, [r read]);
}


- (void)testASpace {
    s = @"a ";
    r = [[PKReader alloc] initWithString:s];
    PKToken *tok = [wordState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    TDEqualObjects(@"a", tok.stringValue);
    TDEqualObjects(@"a", tok.value);
    TDTrue(tok.isWord);
    TDEquals((PKUniChar)' ', [r read]);
}


- (void)testAb {
    s = @"ab";
    r = [[PKReader alloc] initWithString:s];
    PKToken *tok = [wordState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    TDEqualObjects(s, tok.stringValue);
    TDEqualObjects(s, tok.value);
    TDTrue(tok.isWord);
    TDEquals(PKEOF, [r read]);
}


- (void)testAbc {
    s = @"abc";
    r = [[PKReader alloc] initWithString:s];
    PKToken *tok = [wordState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    TDEqualObjects(s, tok.stringValue);
    TDEqualObjects(s, tok.value);
    TDTrue(tok.isWord);
    TDEquals(PKEOF, [r read]);
}


- (void)testItApostropheS {
    s = @"it's";
    r = [[PKReader alloc] initWithString:s];
    PKToken *tok = [wordState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    TDEqualObjects(s, tok.stringValue);
    TDEqualObjects(s, tok.value);
    TDTrue(tok.isWord);
    TDEquals(PKEOF, [r read]);
}


- (void)testTwentyDashFive {
    s = @"twenty-five";
    r = [[PKReader alloc] initWithString:s];
    PKToken *tok = [wordState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    TDEqualObjects(s, tok.stringValue);
    TDEqualObjects(s, tok.value);
    TDTrue(tok.isWord);
    TDEquals(PKEOF, [r read]);
}


- (void)testTwentyUnderscoreFive {
    s = @"twenty_five";
    r = [[PKReader alloc] initWithString:s];
    PKToken *tok = [wordState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    TDEqualObjects(s, tok.stringValue);
    TDEqualObjects(s, tok.value);
    TDTrue(tok.isWord);
    TDEquals(PKEOF, [r read]);
}


- (void)testNumber1 {
    s = @"number1";
    r = [[PKReader alloc] initWithString:s];
    PKToken *tok = [wordState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    TDEqualObjects(s, tok.stringValue);
    TDEqualObjects(s, tok.value);
    TDTrue(tok.isWord);
    TDEquals(PKEOF, [r read]);
}

@end
