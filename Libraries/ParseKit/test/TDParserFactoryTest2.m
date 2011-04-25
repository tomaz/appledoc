//
//  PKParserFactoryTest2.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 5/31/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDParserFactoryTest2.h"

@implementation TDParserFactoryTest2

- (void)setUp {
    factory = [PKParserFactory factory];
}


- (void)testOrVsAndPrecendence {
    g = @"@start = Word | Number Symbol;";
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    
    s = @"foo";
    res = [lp completeMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[foo]foo^", [res description]);
    
    s = @"foo %";
    res = [lp completeMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDNil(res);
    
    g = @"@start = Word Number | Symbol;";
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    
    s = @"foo 3";
    res = [lp completeMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[foo, 3]foo/3^", [res description]);
    
    s = @"%";
    res = [lp completeMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[%]%^", [res description]);

    s = @"foo %";
    res = [lp completeMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDNil(res);
    
    g = @"@start = Word (Number | Symbol);";
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    
    s = @"foo 3";
    res = [lp completeMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[foo, 3]foo/3^", [res description]);
    
    s = @"foo";
    res = [lp completeMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDNil(res);
    
    s = @"foo %";
    res = [lp completeMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[foo, %]foo/%^", [res description]);
}


- (void)test1 {
    g = @"@start = (Word | Number)*;";
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);

    s = @"foo";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[foo]foo^", [res description]);

    s = @"24.5";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[24.5]24.5^", [res description]);

    s = @"foo bar 2 baz";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[foo, bar, 2, baz]foo/bar/2/baz^", [res description]);
    
    s = @"foo bar 2 4 baz";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[foo, bar, 2, 4, baz]foo/bar/2/4/baz^", [res description]);
}


- (void)test2 {
    g = @"@start = (Word | Number)* QuotedString;";
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    
    s = @"foo 'bar'";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[foo, 'bar']foo/'bar'^", [res description]);
    
    s = @"24.5 'bar'";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[24.5, 'bar']24.5/'bar'^", [res description]);
    
    s = @"foo bar 2 baz 'bar'";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[foo, bar, 2, baz, 'bar']foo/bar/2/baz/'bar'^", [res description]);
    
    s = @"foo bar 2 4 baz 'bar'";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[foo, bar, 2, 4, baz, 'bar']foo/bar/2/4/baz/'bar'^", [res description]);
}


- (void)test3 {
    g = @"@start = (Word | Number)* '$'+ QuotedString;";
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    
    s = @"foo $ 'bar'";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[foo, $, 'bar']foo/$/'bar'^", [res description]);
    
    s = @"foo $ $ 'bar'";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[foo, $, $, 'bar']foo/$/$/'bar'^", [res description]);
    
    s = @"24.5 $ 'bar'";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[24.5, $, 'bar']24.5/$/'bar'^", [res description]);
    
    s = @"foo bar 2 baz $ 'bar'";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[foo, bar, 2, baz, $, 'bar']foo/bar/2/baz/$/'bar'^", [res description]);
    
    s = @"foo bar 2 4 baz $ 'bar'";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[foo, bar, 2, 4, baz, $, 'bar']foo/bar/2/4/baz/$/'bar'^", [res description]);
}


- (void)test4 {
    g = @"@start = (Word | Number)* ('$' '%')+ QuotedString;";
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    
    s = @"foo $ % 'bar'";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[foo, $, %, 'bar']foo/$/%/'bar'^", [res description]);
    
    s = @"foo $ % $ % 'bar'";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[foo, $, %, $, %, 'bar']foo/$/%/$/%/'bar'^", [res description]);
}


- (void)test5 {
    g = @"@start = (Word | Number)* ('$' '%')+ QuotedString;";
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    
    s = @"foo $ % 'bar'";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[foo, $, %, 'bar']foo/$/%/'bar'^", [res description]);
    
    s = @"foo $ % $ % 'bar'";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[foo, $, %, $, %, 'bar']foo/$/%/$/%/'bar'^", [res description]);
    
    s = @"foo 33 4 $ % $ % 'bar'";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[foo, 33, 4, $, %, $, %, 'bar']foo/33/4/$/%/$/%/'bar'^", [res description]);
    
    s = @"foo 33 bar 4 $ % $ % 'bar'";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[foo, 33, bar, 4, $, %, $, %, 'bar']foo/33/bar/4/$/%/$/%/'bar'^", [res description]);
}


- (void)test6 {
    g = @"@start = ((Word | Number)* ('$' '%')+) | QuotedString;";
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    
    s = @"'bar'";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"['bar']'bar'^", [res description]);
    
    s = @"foo $ % $ %";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[foo, $, %, $, %]foo/$/%/$/%^", [res description]);
}


- (void)test7 {
    g = @"@start = ((Word | Number)* ('$' '%')+) | QuotedString+;";
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    
    s = @"'bar' 'foo'";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"['bar', 'foo']'bar'/'foo'^", [res description]);
    
    s = @"foo $ % $ %";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[foo, $, %, $, %]foo/$/%/$/%^", [res description]);

    s = @"$ % $ %";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[$, %, $, %]$/%/$/%^", [res description]);
}


- (void)test8 {
    g = @"@start = ((Word | Number)* ('$' '%')+) | QuotedString+;";
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    
    s = @"'bar' 'foo'";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"['bar', 'foo']'bar'/'foo'^", [res description]);
    
    s = @"foo $ % $ %";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[foo, $, %, $, %]foo/$/%/$/%^", [res description]);
    
    s = @"$ % $ %";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[$, %, $, %]$/%/$/%^", [res description]);
}


- (void)test9 {
    g = @"@start = Word | (Number);";
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    
    s = @"42";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[42]42^", [res description]);
    
    s = @"foo";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[foo]foo^", [res description]);
}


- (void)test10 {
    g = @"@start = Word | (Number QuotedString);";
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    
    s = @"foo";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[foo]foo^", [res description]);

    s = @"42 'bar'";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[42, 'bar']42/'bar'^", [res description]);
}


- (void)test11 {
    g = @"@start = ((Word | Number)* | ('$' '%')+) QuotedString+;";
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);

    s = @"foo 'bar'";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[foo, 'bar']foo/'bar'^", [res description]);
    
    s = @"$ % $ % 'bar'";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[$, %, $, %, 'bar']$/%/$/%/'bar'^", [res description]);
}


- (void)test12 {
    g = @"@delimitState = '$'; @delimitedString = '$' '%' nil; @start = DelimitedString('$', '%');";
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    
    s = @"$foo%";
    t = lp.tokenizer;
    t.string = s;
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[$foo%]$foo%^", [res description]);
    
    
    g = @"@delimitState = '$'; @delimitedString = '$' '%' nil; @start = DelimitedString('$', '');";
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    
    s = @"$foo%";
    t = lp.tokenizer;
    t.string = s;
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[$foo%]$foo%^", [res description]);
    
    
    g = @"@delimitState = '$'; @delimitedString = '$' '%' 'fo'; @start = DelimitedString('$', '%');";
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    
    s = @"$foo%";
    t = lp.tokenizer;
    t.string = s;
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[$foo%]$foo%^", [res description]);

    
    g = @"@delimitState = '$'; @delimitedString = '$' '%' 'f'; @start = DelimitedString('$', '%');";
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    
    s = @"$foo%";
    t = lp.tokenizer;
    t.string = s;
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDNil(res);
}


- (void)testWhitespace {
    g = @"@reportsWhitespaceTokens = YES; @start = 'foo' S '+' S 'bar';";
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);

    s = @"foo + bar";
    t = lp.tokenizer;
    t.string = s;
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[foo,  , +,  , bar]foo/ /+/ /bar^", [res description]);

    s = @"foo +bar";
    t = lp.tokenizer;
    t.string = s;
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDNil(res);

    g = @"@start = 'foo' S '+' S 'bar';";
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    
    s = @"foo + bar";
    t = lp.tokenizer;
    t.string = s;
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDNil(res);

    g = @"@reportsWhitespaceTokens = NO; @start = 'foo' S '+' S 'bar';";
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    
    s = @"foo + bar";
    t = lp.tokenizer;
    t.string = s;
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDNil(res);


    g = @"@reportsWhitespaceTokens = YES; @start = 'foo' S '+' S 'bar';";
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    
    s = @"foo  \t \t +  bar";
    t = lp.tokenizer;
    t.string = s;
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[foo,   \t \t , +,   , bar]foo/  \t \t /+/  /bar^", [res description]);
}    


- (void)testDiscard {
    g = @"@start = 'foo'!;";
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    
    s = @"foo";
    t = lp.tokenizer;
    t.string = s;
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[]foo^", [res description]);

    g = @"@start = /foo/!;";
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    
    s = @"foo";
    t = lp.tokenizer;
    t.string = s;
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[]foo^", [res description]);

    g = @"@delimitState='<'; @delimitedStrings='<%' '%>' nil; @start=DelimitedString('<%', '%>')!;";
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    
    s = @"<% foo %>";
    t = lp.tokenizer;
    t.string = s;
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[]<% foo %>^", [res description]);
}


- (void)testDiscard2 {
    g = @"@reportsWhitespaceTokens=YES;@start=S!;";
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    
    s = @" ";
    t = lp.tokenizer;
    t.string = s;
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[] ^", [res description]);
    
    g = @"@start=Any!;";
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    
    s = @"foo";
    t = lp.tokenizer;
    t.string = s;
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[]foo^", [res description]);
    
    g = @"@start=Word!;";
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    
    s = @"foo";
    t = lp.tokenizer;
    t.string = s;
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[]foo^", [res description]);
    
}


- (void)testComments {
    g = 
        @"@commentState = '/';"
        @"@singleLineComments = '//';"
        @"@reportsCommentTokens = YES;"
        @"@start = Any+;";
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);

    s = @"# // foo";
    t = lp.tokenizer;
    t.string = s;
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[#, // foo]#/// foo^", [res description]);

    tok = [res pop];
    TDTrue(tok.isComment);

}    
    


- (void)testFallbackState {
    g = 
        @"@commentState = '/';"
        @"@commentState.fallbackState = delimitState;"
        @"@delimitedString = '/' '/' nil;"
        @"@singleLineComments = '//';"
        @"@multiLineComments = '/*' '*/';"
        @"@start = Any+;";
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);

    s = @"/ %";
    t = lp.tokenizer;

    t.string = s;
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[/, %]//%^", [res description]);
    tok = [res pop];
    TDTrue(tok.isSymbol);

    s = @"/ /";
    t = lp.tokenizer;
    t.string = s;
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[/ /]/ /^", [res description]);
    tok = [res pop];
    TDTrue(tok.isDelimitedString);

    s = @"/foo/";
    t = lp.tokenizer;
    t.string = s;
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[/foo/]/foo/^", [res description]);
    tok = [res pop];
    TDTrue(tok.isDelimitedString);

    s = @"# // foo";
    t = lp.tokenizer;
    t.string = s;
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[#]#^", [res description]);
    tok = [res pop];
    TDTrue(tok.isSymbol);
    
}


- (void)testPatternPredicate1 {
    g = @"@wordChar = ':'; @start = Word;";
    
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    t = lp.tokenizer;
    
    s = @"foo:bar";
    t.string = s;
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[foo:bar]foo:bar^", [res description]);
    tok = [res pop];
    TDTrue(tok.isWord);    
    
    g = @"@wordChar = ':'; @start = Word & /[^:]+/;";
    
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    t = lp.tokenizer;
    
    s = @"foo";
    t.string = s;
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[foo]foo^", [res description]);
    tok = [res pop];
    TDTrue(tok.isWord);
    
    s = @"foo:bar";
    t.string = s;
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDNil(res);
}


- (void)testPatternPredicate2 {
    g = @"@wordChar = ':'; @start=ncName+; name=Word; ncName=name & /[^:]+/;";
    
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    t = lp.tokenizer;
    
    s = @"foo";
    t.string = s;
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[foo]foo^", [res description]);
    tok = [res pop];
    TDTrue(tok.isWord);
    
    s = @"foo:bar";
    t.string = s;
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDNil(res);
}


- (void)testExclusionFoo {
    g = @"@start = ex; ex = Word - 'foo';";
    
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    t = lp.tokenizer;
    
    s = @"bar";
    t.string = s;
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[bar]bar^", [res description]);
    
    s = @"foo";
    t.string = s;
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDNil(res);
    
    s = @"wee";
    t.string = s;
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[wee]wee^", [res description]);    
}


- (void)testExclusionAlt {
    g = @"@start = ex; m = ('foo'|'bar'); ex = Word - m;";

    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    t = lp.tokenizer;
    
    s = @"baz";
    t.string = s;
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[baz]baz^", [res description]);
    
    s = @"foo";
    t.string = s;
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDNil(res);
    
    s = @"wee";
    t.string = s;
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[wee]wee^", [res description]);
}


- (void)testExclusionAlt2 {
    g = @"@start = ex; ex = Word - ('foo'|'bar');";
    
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    t = lp.tokenizer;
    
    s = @"baz";
    t.string = s;
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[baz]baz^", [res description]);
    
    s = @"foo";
    t.string = s;
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDNil(res);
    
    s = @"wee";
    t.string = s;
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[wee]wee^", [res description]);
}


- (void)testExclusionAlt3 {
    g = @"@start = ex; s = 'foo'|'baz'; m = ('foo'|'bar'); ex = s - m;";
    
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    t = lp.tokenizer;
    
    s = @"baz";
    t.string = s;
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[baz]baz^", [res description]);
    
    s = @"foo";
    t.string = s;
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDNil(res);
    
    s = @"wee";
    t.string = s;
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDNil(res);
}


- (void)testExclusionAlt4 {
    g = @"@start = ex; m = ('foo'|'bar'); ex = ('foo'|'baz') - m;";
    
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    t = lp.tokenizer;
    
    s = @"baz";
    t.string = s;
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[baz]baz^", [res description]);
    
    s = @"foo";
    t.string = s;
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDNil(res);
    
    s = @"wee";
    t.string = s;
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDNil(res);
}


- (void)testExclusionAlt5 {
    g = @"@start = ex; ex = ('foo'|'baz') - ('foo'|'bar');";
    
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    t = lp.tokenizer;
    
    s = @"baz";
    t.string = s;
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[baz]baz^", [res description]);
    
    s = @"foo";
    t.string = s;
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDNil(res);
    
    s = @"wee";
    t.string = s;
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDNil(res);
}

@end
