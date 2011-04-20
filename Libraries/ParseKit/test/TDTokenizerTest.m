//
//  PKTokenizerTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/11/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDTokenizerTest.h"
#import "ParseKit.h"

@implementation TDTokenizerTest

- (void)setUp {
}


- (void)tearDown {
}


- (void)testBlastOff {
    s = @"\"It's 123 blast-off!\", she said, // watch out!\n"
                    @"and <= 3 'ticks' later /* wince */, it's blast-off!";
    t = [PKTokenizer tokenizerWithString:s];
    
    PKToken *eof = [PKToken EOFToken];
    PKToken *tok = nil;
    
    //NSLog(@"\n\n starting!!! \n\n");
    while ((tok = [t nextToken]) != eof) {
        //NSLog(@"(%@)", tok.stringValue);
    }
    //NSLog(@"\n\n done!!! \n\n");
    
}

- (void)testStuff {
    s = @"2 != 47. Blast-off!! 'Woo-hoo!'";
    t = [PKTokenizer tokenizerWithString:s];
    
    PKToken *eof = [PKToken EOFToken];
    PKToken *tok = nil;
    
    while ((tok = [t nextToken]) != eof) {
        //NSLog(@"(%@) (%.1f) : %@", tok.stringValue, tok.floatValue, [tok debugDescription]);
    }
}


- (void)testStuff2 {
    s = @"2 != 47. Blast-off!! 'Woo-hoo!'";
    t = [PKTokenizer tokenizerWithString:s];
    
    PKToken *eof = [PKToken EOFToken];
    PKToken *tok = nil;
    
    tok = [t nextToken];
    TDNotNil(tok);
    TDTrue(tok != eof);
    TDTrue(tok.isNumber);
    TDEqualObjects(tok.stringValue, @"2");
    TDEqualObjects(tok.value, [NSNumber numberWithFloat:2.0]);
    TDEquals(tok.offset, (NSUInteger)0);

    tok = [t nextToken];
    TDNotNil(tok);
    TDTrue(tok != eof);
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"!=");
    TDEqualObjects(tok.value, @"!=");
    TDEquals(tok.offset, (NSUInteger)2);

    tok = [t nextToken];
    TDNotNil(tok);
    TDTrue(tok != eof);
    TDTrue(tok.isNumber);
    TDEqualObjects(tok.stringValue, @"47");
    TDEqualObjects(tok.value, [NSNumber numberWithFloat:47.0]);
    TDEquals(tok.offset, (NSUInteger)5);
    
    tok = [t nextToken];
    TDNotNil(tok);
    TDTrue(tok != eof);
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @".");
    TDEqualObjects(tok.value, @".");
    TDEquals(tok.offset, (NSUInteger)7);
    
    tok = [t nextToken];
    TDNotNil(tok);
    TDTrue(tok != eof);
    TDTrue(tok.isWord);
    TDEqualObjects(tok.stringValue, @"Blast-off");
    TDEqualObjects(tok.value, @"Blast-off");
    TDEquals(tok.offset, (NSUInteger)9);
    
    tok = [t nextToken];
    TDNotNil(tok);
    TDTrue(tok != eof);
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"!");
    TDEqualObjects(tok.value, @"!");
    TDEquals(tok.offset, (NSUInteger)18);
    
    tok = [t nextToken];
    TDNotNil(tok);
    TDTrue(tok != eof);
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"!");
    TDEqualObjects(tok.value, @"!");
    TDEquals(tok.offset, (NSUInteger)19);
    
    tok = [t nextToken];
    TDNotNil(tok);
    TDTrue(tok != eof);
    TDTrue(tok.isQuotedString);
    TDEqualObjects(tok.stringValue, @"'Woo-hoo!'");
    TDEqualObjects(tok.value, @"'Woo-hoo!'");
    TDEquals(tok.offset, (NSUInteger)21);
    
    tok = [t nextToken];
    TDNotNil(tok);
    TDTrue(tok == eof);
    TDEquals(tok.offset, (NSUInteger)PKEOF);
}


- (void)testFortySevenDot {
    s = @"47.";
    t = [PKTokenizer tokenizerWithString:s];
    
    PKToken *eof = [PKToken EOFToken];
    PKToken *tok = nil;
    tok = [t nextToken];
    TDNotNil(tok);
    TDTrue(tok != eof);
    TDTrue(tok.isNumber);
    TDEqualObjects(tok.stringValue, @"47");
    TDEqualObjects(tok.value, [NSNumber numberWithFloat:47.0]);
    TDEquals(tok.offset, (NSUInteger)0);
    
    tok = [t nextToken];
    TDNotNil(tok);
    TDTrue(tok != eof);
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @".");
    TDEqualObjects(tok.value, @".");
    TDEquals(tok.offset, (NSUInteger)2);
    
    tok = [t nextToken];
    TDNotNil(tok);
    TDTrue(tok == eof);
    TDEquals(tok.offset, (NSUInteger)PKEOF);
}


- (void)testFortySevenDotSpaceFoo {
    s = @"47. foo";
    t = [PKTokenizer tokenizerWithString:s];
    
    PKToken *eof = [PKToken EOFToken];
    PKToken *tok = nil;
    tok = [t nextToken];
    TDNotNil(tok);
    TDTrue(tok != eof);
    TDTrue(tok.isNumber);
    TDEqualObjects(tok.stringValue, @"47");
    TDEqualObjects(tok.value, [NSNumber numberWithFloat:47.0]);
    TDEquals(tok.offset, (NSUInteger)0);
    
    tok = [t nextToken];
    TDNotNil(tok);
    TDTrue(tok != eof);
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @".");
    TDEqualObjects(tok.value, @".");
    TDEquals(tok.offset, (NSUInteger)2);
    
    tok = [t nextToken];
    TDNotNil(tok);
    TDTrue(tok != eof);
    TDTrue(tok.isWord);
    TDEqualObjects(tok.stringValue, @"foo");
    TDEqualObjects(tok.value, @"foo");
    TDEquals(tok.offset, (NSUInteger)4);
    
    tok = [t nextToken];
    TDNotNil(tok);
    TDTrue(tok == eof);
    TDEquals(tok.offset, (NSUInteger)PKEOF);
}


- (void)testDotOne {
    s = @"   .999";
    t = [PKTokenizer tokenizerWithString:s];
    
    PKToken *tok = [t nextToken];
    STAssertEqualsWithAccuracy((CGFloat)0.999, tok.floatValue, 0.01, @"");
    TDTrue(tok.isNumber);
    TDEquals(tok.offset, (NSUInteger)3);

//    if ([PKToken EOFToken] == token) break;
    
}


- (void)testSpaceDotSpace {
    s = @" . ";
    t = [PKTokenizer tokenizerWithString:s];
    
    PKToken *tok = [t nextToken];
    TDEqualObjects(@".", tok.stringValue);
    TDTrue(tok.isSymbol);
    TDEquals(tok.offset, (NSUInteger)1);

    //    if ([PKToken EOFToken] == token) break;
    
}


- (void)testInitSig {
    s = @"- (id)init {";
    t = [PKTokenizer tokenizerWithString:s];
    
    PKToken *tok = [t nextToken];
    TDEqualObjects(@"-", tok.stringValue);
    TDEquals((CGFloat)0.0, tok.floatValue);
    TDTrue(tok.isSymbol);
    TDEquals(tok.offset, (NSUInteger)0);

    tok = [t nextToken];
    TDEqualObjects(@"(", tok.stringValue);
    TDEquals((CGFloat)0.0, tok.floatValue);
    TDTrue(tok.isSymbol);
    TDEquals(tok.offset, (NSUInteger)2);
}


- (void)testInitSig2 {
    s = @"-(id)init {";
    t = [PKTokenizer tokenizerWithString:s];
    
    PKToken *tok = [t nextToken];
    TDEqualObjects(@"-", tok.stringValue);
    TDEquals((CGFloat)0.0, tok.floatValue);
    TDTrue(tok.isSymbol);
    TDEquals(tok.offset, (NSUInteger)0);
	
    tok = [t nextToken];
    TDEqualObjects(@"(", tok.stringValue);
    TDEquals((CGFloat)0.0, tok.floatValue);
    TDTrue(tok.isSymbol);
    TDEquals(tok.offset, (NSUInteger)1);
}


- (void)testMinusSpaceTwo {
    s = @"- 2";
    t = [PKTokenizer tokenizerWithString:s];
    
    PKToken *tok = [t nextToken];
    TDEqualObjects(@"-", tok.stringValue);
    TDEquals((CGFloat)0.0, tok.floatValue);
    TDTrue(tok.isSymbol);
    TDEquals(tok.offset, (NSUInteger)0);

    tok = [t nextToken];
    TDEqualObjects(@"2", tok.stringValue);
    TDEquals((CGFloat)2.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEquals(tok.offset, (NSUInteger)2);
}


- (void)testMinusPlusTwo {
    s = @"+2";
    t = [PKTokenizer tokenizerWithString:s];
    
    PKToken *tok = [t nextToken];
    TDEqualObjects(@"+", tok.stringValue);
    TDTrue(tok.isSymbol);
    TDEquals(tok.offset, (NSUInteger)0);

    tok = [t nextToken];
    TDEquals((CGFloat)2.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"2", tok.stringValue);
    TDEquals(tok.offset, (NSUInteger)1);

    TDEquals([PKToken EOFToken], [t nextToken]);
}


- (void)testMinusPlusTwoCustom {
    s = @"+2";
    t = [PKTokenizer tokenizerWithString:s];
    [t setTokenizerState:t.numberState from:'+' to:'+'];
    
    PKToken *tok = [t nextToken];
    TDEquals((CGFloat)2.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"+2", tok.stringValue);
    TDEquals(tok.offset, (NSUInteger)0);
    
    TDEquals([PKToken EOFToken], [t nextToken]);
}


- (void)testSimpleAPIUsage {
    s = @".    ,    ()  12.33333 .:= .456\n\n>=<     'boooo'fasa  this should /*     not*/ appear \r /*but  */this should >=<//n't";

    t = [PKTokenizer tokenizerWithString:s];
    
    [t.symbolState add:@":="];
    [t.symbolState add:@">=<"];
    
    NSMutableArray *toks = [NSMutableArray array];
    
    PKToken *eof = [PKToken EOFToken];
    PKToken *token = nil;
    while (token = [t nextToken]) {
        if (eof == token) break;
        
        [toks addObject:token];

    }

    //NSLog(@"\n\n\n\ntoks: %@\n\n\n\n", toks);
}


- (void)testKatakana1 {
    s = @"ア";
    t = [PKTokenizer tokenizerWithString:s];
    
    PKToken *eof = [PKToken EOFToken];
    PKToken *tok = [t nextToken];
    
    TDNotNil(tok);
    TDTrue(tok.isWord);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.offset, (NSUInteger)0);
    
    tok = [t nextToken];
    TDEqualObjects(eof, tok);
}


- (void)testKatakana2 {
    s = @"アア";
    t = [PKTokenizer tokenizerWithString:s];
    
    PKToken *eof = [PKToken EOFToken];
    PKToken *tok = [t nextToken];
    
    TDNotNil(tok);
    TDTrue(tok.isWord);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.offset, (NSUInteger)0);
    
    tok = [t nextToken];
    TDEqualObjects(eof, tok);
}


- (void)testKatakana3 {
    s = @"アェ";
    t = [PKTokenizer tokenizerWithString:s];
    
    PKToken *eof = [PKToken EOFToken];
    PKToken *tok = [t nextToken];
    
    TDNotNil(tok);
    TDTrue(tok.isWord);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.offset, (NSUInteger)0);
    
    tok = [t nextToken];
    TDEqualObjects(eof, tok);
}


- (void)testParenStuff {
    s = @"-(ab+5)";
    t = [PKTokenizer tokenizerWithString:s];
	
	PKToken *tok = [t nextToken];
	TDTrue(tok.isSymbol);
	TDEqualObjects(tok.stringValue, @"-");
	TDEquals((CGFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)0);
	
	tok = [t nextToken];
	TDTrue(tok.isSymbol);
	TDEqualObjects(tok.stringValue, @"(");
	TDEquals((CGFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)1);
	
	tok = [t nextToken];
	TDTrue(tok.isWord);
	TDEqualObjects(tok.stringValue, @"ab");
	TDEquals((CGFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)2);
	
	tok = [t nextToken];
	TDTrue(tok.isSymbol);
	TDEqualObjects(tok.stringValue, @"+");
	TDEquals((CGFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)4);
	
	tok = [t nextToken];
	TDTrue(tok.isNumber);
	TDEqualObjects(tok.stringValue, @"5");
	TDEquals((CGFloat)5.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)5);
	
	tok = [t nextToken];
	TDTrue(tok.isSymbol);
	TDEqualObjects(tok.stringValue, @")");
	TDEquals((CGFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)6);
}


- (void)testParenStuff2 {
    s = @"- (ab+5)";
    t = [PKTokenizer tokenizerWithString:s];
	t.whitespaceState.reportsWhitespaceTokens = YES;
	
	PKToken *tok = [t nextToken];
	TDTrue(tok.isSymbol);
	TDEqualObjects(tok.stringValue, @"-");
	TDEquals((CGFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)0);
	
	tok = [t nextToken];
	TDTrue(tok.isWhitespace);
	TDEqualObjects(tok.stringValue, @" ");
	TDEquals((CGFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)1);
	
	tok = [t nextToken];
	TDTrue(tok.isSymbol);
	TDEqualObjects(tok.stringValue, @"(");
	TDEquals((CGFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)2);
	
	tok = [t nextToken];
	TDTrue(tok.isWord);
	TDEqualObjects(tok.stringValue, @"ab");
	TDEquals((CGFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)3);
}


- (void)testParenStuff3 {
    s = @"+(ab+5)";
    t = [PKTokenizer tokenizerWithString:s];
	
	PKToken *tok = [t nextToken];
	TDTrue(tok.isSymbol);
	TDEqualObjects(tok.stringValue, @"+");
	TDEquals((CGFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)0);
	
	tok = [t nextToken];
	TDTrue(tok.isSymbol);
	TDEqualObjects(tok.stringValue, @"(");
	TDEquals((CGFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)1);
	
	tok = [t nextToken];
	TDTrue(tok.isWord);
	TDEqualObjects(tok.stringValue, @"ab");
	TDEquals((CGFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)2);
	
	tok = [t nextToken];
	TDTrue(tok.isSymbol);
	TDEqualObjects(tok.stringValue, @"+");
	TDEquals((CGFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)4);
	
	tok = [t nextToken];
	TDTrue(tok.isNumber);
	TDEqualObjects(tok.stringValue, @"5");
	TDEquals((CGFloat)5.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)5);
	
	tok = [t nextToken];
	TDTrue(tok.isSymbol);
	TDEqualObjects(tok.stringValue, @")");
	TDEquals((CGFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)6);
}


- (void)testParenStuff4 {
    s = @"+ (ab+5)";
    t = [PKTokenizer tokenizerWithString:s];
	t.whitespaceState.reportsWhitespaceTokens = YES;
	
	PKToken *tok = [t nextToken];
	TDTrue(tok.isSymbol);
	TDEqualObjects(tok.stringValue, @"+");
	TDEquals((CGFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)0);
	
	tok = [t nextToken];
	TDTrue(tok.isWhitespace);
	TDEqualObjects(tok.stringValue, @" ");
	TDEquals((CGFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)1);

	tok = [t nextToken];
	TDTrue(tok.isSymbol);
	TDEqualObjects(tok.stringValue, @"(");
	TDEquals((CGFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)2);
	
	tok = [t nextToken];
	TDTrue(tok.isWord);
	TDEqualObjects(tok.stringValue, @"ab");
	TDEquals((CGFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)3);
}


- (void)testParenStuff5 {
    s = @".(ab+5)";
    t = [PKTokenizer tokenizerWithString:s];
	
	PKToken *tok = [t nextToken];
	TDTrue(tok.isSymbol);
	TDEqualObjects(tok.stringValue, @".");
	TDEquals((CGFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)0);
	
	tok = [t nextToken];
	TDTrue(tok.isSymbol);
	TDEqualObjects(tok.stringValue, @"(");
	TDEquals((CGFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)1);
	
	tok = [t nextToken];
	TDTrue(tok.isWord);
	TDEqualObjects(tok.stringValue, @"ab");
	TDEquals((CGFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)2);
	
	tok = [t nextToken];
	TDTrue(tok.isSymbol);
	TDEqualObjects(tok.stringValue, @"+");
	TDEquals((CGFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)4);
	
	tok = [t nextToken];
	TDTrue(tok.isNumber);
	TDEqualObjects(tok.stringValue, @"5");
	TDEquals((CGFloat)5.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)5);
	
	tok = [t nextToken];
	TDTrue(tok.isSymbol);
	TDEqualObjects(tok.stringValue, @")");
	TDEquals((CGFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)6);
}


- (void)testParenStuff6 {
    s = @". (ab+5)";
    t = [PKTokenizer tokenizerWithString:s];
	t.whitespaceState.reportsWhitespaceTokens = YES;
	
	PKToken *tok = [t nextToken];
	TDTrue(tok.isSymbol);
	TDEqualObjects(tok.stringValue, @".");
	TDEquals((CGFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)0);

	tok = [t nextToken];
	TDTrue(tok.isWhitespace);
	TDEqualObjects(tok.stringValue, @" ");
	TDEquals((CGFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)1);
	
	tok = [t nextToken];
	TDTrue(tok.isSymbol);
	TDEqualObjects(tok.stringValue, @"(");
	TDEquals((CGFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)2);

	tok = [t nextToken];
	TDTrue(tok.isWord);
	TDEqualObjects(tok.stringValue, @"ab");
	TDEquals((CGFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)3);
}


- (void)testParenStuff7 {
    s = @"-(ab+5)";
    t = [PKTokenizer tokenizerWithString:s];
    
    NSMutableString *final = [NSMutableString string];
    
    PKToken *eof = [PKToken EOFToken];
    PKToken *tok = nil;
    while ((tok = [t nextToken]) != eof) {
        [final appendString:[tok stringValue]];
    }
    
    TDNotNil(tok);
    TDEqualObjects(final, s);
    TDEqualObjects(eof, [t nextToken]);
}

@end
