//
//  PKSymbolStateTestok.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/12/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDSymbolStateTest.h"

@implementation TDSymbolStateTest

- (void)setUp {
    symbolState = [[PKSymbolState alloc] init];
}


- (void)tearDown {
    [symbolState release];
    [r release];
}


- (void)testDot {
    s = @".";
    r = [[PKReader alloc] initWithString:s];
    PKToken *tok = [symbolState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    TDEqualObjects(@".", tok.stringValue);
    TDEqualObjects(@".", tok.value);
    TDTrue(tok.isSymbol);
    TDEquals(PKEOF, [r read]);
}


- (void)testDotA {
    s = @".a";
    r = [[PKReader alloc] initWithString:s];
    PKToken *tok = [symbolState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    TDEqualObjects(@".", tok.stringValue);
    TDEqualObjects(@".", tok.value);
    TDTrue(tok.isSymbol);
    TDEquals((PKUniChar)'a', [r read]);
}


- (void)testDotSpace {
    s = @". ";
    r = [[PKReader alloc] initWithString:s];
    PKToken *tok = [symbolState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    TDEqualObjects(@".", tok.stringValue);
    TDEqualObjects(@".", tok.value);
    TDTrue(tok.isSymbol);
    TDEquals((PKUniChar)' ', [r read]);
}


- (void)testDotDot {
    s = @"..";
    r = [[PKReader alloc] initWithString:s];
    PKToken *tok = [symbolState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    TDEqualObjects(@".", tok.stringValue);
    TDEqualObjects(@".", tok.value);
    TDTrue(tok.isSymbol);
    TDEquals((PKUniChar)'.', [r read]);
}



- (void)testAddDotDot {
    s = @"..";
    [symbolState add:s];
    r = [[PKReader alloc] initWithString:s];
    PKToken *tok = [symbolState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    TDEqualObjects(@"..", tok.stringValue);
    TDEqualObjects(@"..", tok.value);
    TDTrue(tok.isSymbol);
    TDEquals(PKEOF, [r read]);
}


- (void)testAddDotDotSpace {
    s = @".. ";
    [symbolState add:@".."];
    r = [[PKReader alloc] initWithString:s];
    PKToken *tok = [symbolState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    TDEqualObjects(@"..", tok.stringValue);
    TDEqualObjects(@"..", tok.value);
    TDTrue(tok.isSymbol);
    TDEquals((PKUniChar)' ', [r read]);
}


- (void)testAddColonEqual {
    s = @":=";
    [symbolState add:s];
    r = [[PKReader alloc] initWithString:s];
    PKToken *tok = [symbolState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    TDEqualObjects(@":=", tok.stringValue);
    TDEqualObjects(@":=", tok.value);
    TDTrue(tok.isSymbol);
    TDEquals(PKEOF, [r read]);
}


- (void)testAddColonEqualSpace {
    s = @":= ";
    [symbolState add:@":="];
    r = [[PKReader alloc] initWithString:s];
    PKToken *tok = [symbolState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    TDEqualObjects(@":=", tok.stringValue);
    TDEqualObjects(@":=", tok.value);
    TDTrue(tok.isSymbol);
    TDEquals((PKUniChar)' ', [r read]);
}


- (void)testAddGtEqualLtSpace {
    s = @">=< ";
    [symbolState add:@">=<"];
    r = [[PKReader alloc] initWithString:s];
    PKToken *tok = [symbolState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    TDEqualObjects(@">=<", tok.stringValue);
    TDEqualObjects(@">=<", tok.value);
    TDTrue(tok.isSymbol);
    TDEquals((PKUniChar)' ', [r read]);
}


- (void)testAddGtEqualLt {
    s = @">=<";
    [symbolState add:s];
    r = [[PKReader alloc] initWithString:s];
    PKToken *tok = [symbolState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    TDEqualObjects(@">=<", tok.stringValue);
    TDEqualObjects(@">=<", tok.value);
    TDTrue(tok.isSymbol);
    TDEquals(PKEOF, [r read]);
}


- (void)testTokenzierAddGtEqualLt {
    s = @">=<";
    PKTokenizer *t = [PKTokenizer tokenizerWithString:s];
    [t.symbolState add:s];
    PKToken *tok = [t nextToken];
    TDEqualObjects(@">=<", tok.stringValue);
    TDEqualObjects(@">=<", tok.value);
    TDTrue(tok.isSymbol);
    
    TDEquals([PKToken EOFToken], [t nextToken]);
}


- (void)testTokenzierAddGtEqualLtSpaceFoo {
    s = @">=< foo";
    PKTokenizer *t = [PKTokenizer tokenizerWithString:s];
    [t.symbolState add:@">=<"];
    PKToken *tok = [t nextToken];
    TDEqualObjects(@">=<", tok.stringValue);
    TDEqualObjects(@">=<", tok.value);
    TDTrue(tok.isSymbol);

    tok = [t nextToken];
    TDEqualObjects(@"foo", tok.stringValue);
    TDEqualObjects(@"foo", tok.value);
    TDTrue(tok.isWord);
    
    TDEquals([PKToken EOFToken], [t nextToken]);
}


- (void)testTokenzierAddGtEqualLtFoo {
    s = @">=<foo";
    PKTokenizer *t = [PKTokenizer tokenizerWithString:s];
    [t.symbolState add:@">=<"];
    PKToken *tok = [t nextToken];
    TDEqualObjects(@">=<", tok.stringValue);
    TDEqualObjects(@">=<", tok.value);
    TDTrue(tok.isSymbol);
    
    tok = [t nextToken];
    TDEqualObjects(@"foo", tok.stringValue);
    TDEqualObjects(@"foo", tok.value);
    TDTrue(tok.isWord);
    
    TDEquals([PKToken EOFToken], [t nextToken]);
}


- (void)testTokenzierAddGtEqualLtDot {
    s = @">=<.";
    PKTokenizer *t = [PKTokenizer tokenizerWithString:s];
    [t.symbolState add:@">=<"];
    PKToken *tok = [t nextToken];
    TDEqualObjects(@">=<", tok.stringValue);
    TDEqualObjects(@">=<", tok.value);
    TDTrue(tok.isSymbol);
    
    tok = [t nextToken];
    TDEqualObjects(@".", tok.stringValue);
    TDEqualObjects(@".", tok.value);
    TDTrue(tok.isSymbol);
    
    TDEquals([PKToken EOFToken], [t nextToken]);
}


- (void)testTokenzierAddGtEqualLtSpaceDot {
    s = @">=< .";
    PKTokenizer *t = [PKTokenizer tokenizerWithString:s];
    [t.symbolState add:@">=<"];
    PKToken *tok = [t nextToken];
    TDEqualObjects(@">=<", tok.stringValue);
    TDEqualObjects(@">=<", tok.value);
    TDTrue(tok.isSymbol);
    
    tok = [t nextToken];
    TDEqualObjects(@".", tok.stringValue);
    TDEqualObjects(@".", tok.value);
    TDTrue(tok.isSymbol);
    
    TDEquals([PKToken EOFToken], [t nextToken]);
}


- (void)testTokenzierAddGtEqualLtSpaceDotSpace {
    s = @">=< . ";
    PKTokenizer *t = [PKTokenizer tokenizerWithString:s];
    [t.symbolState add:@">=<"];
    PKToken *tok = [t nextToken];
    TDEqualObjects(@">=<", tok.stringValue);
    TDEqualObjects(@">=<", tok.value);
    TDTrue(tok.isSymbol);
    
    tok = [t nextToken];
    TDEqualObjects(@".", tok.stringValue);
    TDEqualObjects(@".", tok.value);
    TDTrue(tok.isSymbol);
    
    TDEquals([PKToken EOFToken], [t nextToken]);
}


- (void)testTokenzierAddLtBangDashDashSpaceDotSpace {
    s = @"<!-- . ";
    PKTokenizer *t = [PKTokenizer tokenizerWithString:s];
    [t.symbolState add:@"<!--"];
    PKToken *tok = [t nextToken];
    TDEqualObjects(@"<!--", tok.stringValue);
    TDEqualObjects(@"<!--", tok.value);
    TDTrue(tok.isSymbol);
    
    tok = [t nextToken];
    TDEqualObjects(@".", tok.stringValue);
    TDEqualObjects(@".", tok.value);
    TDTrue(tok.isSymbol);
    
    TDEquals([PKToken EOFToken], [t nextToken]);
}


- (void)testTokenzierAddDashDashGt {
    s = @"-->";
    PKTokenizer *t = [PKTokenizer tokenizerWithString:s];
    [t.symbolState add:@"-->"];
    PKToken *tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(@"-->", tok.stringValue);
    TDEqualObjects(@"-->", tok.value);
    
    tok = [t nextToken];
    TDEquals([PKToken EOFToken], [t nextToken]);
}


- (void)testTokenzierAddDashDashGtSpaceDot {
    s = @"--> .";
    PKTokenizer *t = [PKTokenizer tokenizerWithString:s];
    [t.symbolState add:@"-->"];
    PKToken *tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(@"-->", tok.stringValue);
    TDEqualObjects(@"-->", tok.value);
    
    tok = [t nextToken];
    TDEqualObjects(@".", tok.stringValue);
    TDEqualObjects(@".", tok.value);
    TDTrue(tok.isSymbol);
    
    TDEquals([PKToken EOFToken], [t nextToken]);
}


- (void)testTokenzierAddDashDashGtSpaceDotSpace {
    s = @"--> . ";
    PKTokenizer *t = [PKTokenizer tokenizerWithString:s];
    [t.symbolState add:@"-->"];
    PKToken *tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(@"-->", tok.stringValue);
    TDEqualObjects(@"-->", tok.value);
    
    tok = [t nextToken];
    TDEqualObjects(@".", tok.stringValue);
    TDEqualObjects(@".", tok.value);
    TDTrue(tok.isSymbol);
    
    TDEquals([PKToken EOFToken], [t nextToken]);
}


- (void)testTokenzierAddDashDash {
    s = @"--";
    PKTokenizer *t = [PKTokenizer tokenizerWithString:s];
    [t.symbolState add:@"--"];
    PKToken *tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(@"--", tok.stringValue);
    TDEqualObjects(@"--", tok.value);
    
    tok = [t nextToken];
    TDEquals([PKToken EOFToken], [t nextToken]);
}


- (void)testTokenzierAddDashDashSpaceDot {
    s = @"-- .";
    PKTokenizer *t = [PKTokenizer tokenizerWithString:s];
    [t.symbolState add:@"--"];
    PKToken *tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(@"--", tok.stringValue);
    TDEqualObjects(@"--", tok.value);
    
    tok = [t nextToken];
    TDEqualObjects(@".", tok.stringValue);
    TDEqualObjects(@".", tok.value);
    TDTrue(tok.isSymbol);
    
    TDEquals([PKToken EOFToken], [t nextToken]);
}


- (void)testTokenzierAddDashDashSpaceDotSpace {
    s = @"-- . ";
    PKTokenizer *t = [PKTokenizer tokenizerWithString:s];
    [t.symbolState add:@"--"];
    PKToken *tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(@"--", tok.stringValue);
    TDEqualObjects(@"--", tok.value);
    
    tok = [t nextToken];
    TDEqualObjects(@".", tok.stringValue);
    TDEqualObjects(@".", tok.value);
    TDTrue(tok.isSymbol);
    
    TDEquals([PKToken EOFToken], [t nextToken]);
}


- (void)testTokenzierEqualEqualEqualButNotEqual {
    s = @"=";
    PKTokenizer *t = [PKTokenizer tokenizerWithString:s];
    [t.symbolState add:@"==="];
    PKToken *tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(@"=", tok.stringValue);
    TDEqualObjects(@"=", tok.value);
    
    TDEquals([PKToken EOFToken], [t nextToken]);
}


- (void)testTokenzierEqualEqualEqualButNotEqualEqual {
    s = @"==";
    PKTokenizer *t = [PKTokenizer tokenizerWithString:s];
    [t.symbolState add:@"==="];
    PKToken *tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(@"==", tok.stringValue);
    TDEqualObjects(@"==", tok.value);
    
    TDEquals([PKToken EOFToken], [t nextToken]);
}


- (void)testTokenzierEqualEqualEqualCompareEqualEqualEqualEqual {
    s = @"====";
    PKTokenizer *t = [PKTokenizer tokenizerWithString:s];
    [t.symbolState add:@"==="];
    PKToken *tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(@"===", tok.stringValue);
    TDEqualObjects(@"===", tok.value);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(@"=", tok.stringValue);
    TDEqualObjects(@"=", tok.value);
    
    TDEquals([PKToken EOFToken], [t nextToken]);
}


- (void)testTokenzierEqualEqualEqualCompareEqualEqualEqualEqualEqual {
    s = @"=====";
    PKTokenizer *t = [PKTokenizer tokenizerWithString:s];
    [t.symbolState add:@"==="];
    PKToken *tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(@"===", tok.stringValue);
    TDEqualObjects(@"===", tok.value);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(@"==", tok.stringValue);
    TDEqualObjects(@"==", tok.value);
    
    TDEquals([PKToken EOFToken], [t nextToken]);
}


- (void)testTokenzierEqualEqualEqualCompareEqualEqualEqualEqualEqualSpaceEqual {
    s = @"===== =";
    PKTokenizer *t = [PKTokenizer tokenizerWithString:s];
    [t.symbolState add:@"==="];
    PKToken *tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(@"===", tok.stringValue);
    TDEqualObjects(@"===", tok.value);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(@"==", tok.stringValue);
    TDEqualObjects(@"==", tok.value);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(@"=", tok.stringValue);
    TDEqualObjects(@"=", tok.value);
    
    TDEquals([PKToken EOFToken], [t nextToken]);
}


- (void)testTokenzierEqualEqualEqualEqual {
    s = @"====";
    PKTokenizer *t = [PKTokenizer tokenizerWithString:s];
    PKToken *tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(@"==", tok.stringValue);
    TDEqualObjects(@"==", tok.value);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(@"==", tok.stringValue);
    TDEqualObjects(@"==", tok.value);
    
    TDEquals([PKToken EOFToken], [t nextToken]);
}


- (void)testTokenzierEqualColonEqualButNotEqualColon {
    s = @"=:";
    PKTokenizer *t = [PKTokenizer tokenizerWithString:s];
    [t.symbolState add:@"=:="];
    PKToken *tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(@"=", tok.stringValue);
    TDEqualObjects(@"=", tok.value);
    
    tok = [t nextToken];
    TDEqualObjects(@":", tok.stringValue);
    TDEqualObjects(@":", tok.value);
    TDTrue(tok.isSymbol);
    
    TDEquals([PKToken EOFToken], [t nextToken]);
}


- (void)testTokenzierRemoveEqualEqual {
    s = @"==";
    PKTokenizer *t = [PKTokenizer tokenizerWithString:s];
    [t.symbolState remove:@"=="];
    PKToken *tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(@"=", tok.stringValue);
    TDEqualObjects(@"=", tok.value);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(@"=", tok.stringValue);
    TDEqualObjects(@"=", tok.value);
    
    TDEquals([PKToken EOFToken], [t nextToken]);
}


- (void)testTokenzierRemoveEqualEqualAddEqualEqual {
    s = @"====";
    PKTokenizer *t = [PKTokenizer tokenizerWithString:s];
    [t.symbolState remove:@"=="];
    PKToken *tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(@"=", tok.stringValue);
    TDEqualObjects(@"=", tok.value);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(@"=", tok.stringValue);
    TDEqualObjects(@"=", tok.value);
    
    [t.symbolState add:@"=="];

    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(@"==", tok.stringValue);
    TDEqualObjects(@"==", tok.value);
    
    TDEquals([PKToken EOFToken], [t nextToken]);
}


- (void)testTokenzierEqualColonEqualAndThenEqualColonEqualColon {
    s = @"=:=:";
    PKTokenizer *t = [PKTokenizer tokenizerWithString:s];
    [t.symbolState add:@"=:="];
    PKToken *tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(@"=:=", tok.stringValue);
    TDEqualObjects(@"=:=", tok.value);
    
    tok = [t nextToken];
    TDEqualObjects(@":", tok.stringValue);
    TDEqualObjects(@":", tok.value);
    TDTrue(tok.isSymbol);
    
    TDEquals([PKToken EOFToken], [t nextToken]);
}


- (void)testTrickyCase {
    s = @"+++\n+++-\n+++-+";
    
    PKTokenizer *t = [PKTokenizer tokenizerWithString:s];
    [t.symbolState add:@"+++"];
    [t.symbolState add:@"+++-+"];
    
    PKToken *eof = [PKToken EOFToken];
    
    PKToken *tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"+++");
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"+++");
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"-");
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"+++-+");
    
    tok = [t nextToken];
    TDEquals(eof, tok);
}

@end
