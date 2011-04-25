//
//  PKParserFactoryTest3.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 6/27/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDParserFactoryTest3.h"

@implementation TDParserFactoryTest3

- (void)setUp {
    factory = [PKParserFactory factory];
}


- (void)testOrVsAndPrecendence {
    g = @" @start ( didMatchFoo: ) = foo;\n"
    @"  foo = Word & /foo/ | Number! { 1 } ( DelimitedString ( '/' , '/' ) Symbol- '%' ) * /bar/ ;";
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    
    s = @"foo";
    res = [lp completeMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[foo]foo^", [res description]);
}


- (void)testNegation {
    g = @"@start = ~'foo';";
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    
    s = @"foo";
    res = [lp completeMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDNil(res);
    
    s = @"'bar'";
    res = [lp completeMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"['bar']'bar'^", [res description]);
    
    s = @"bar";
    res = [lp completeMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[bar]bar^", [res description]);
}


- (void)testNegateSymbol {
    g = @"@start = ~Symbol;";
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    
    s = @"1";
    res = [lp completeMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[1]1^", [res description]);
    
    s = @"'bar'";
    res = [lp completeMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"['bar']'bar'^", [res description]);
    
    s = @"bar";
    res = [lp completeMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[bar]bar^", [res description]);

    s = @"$";
    res = [lp completeMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDNil(res);
    
}


- (void)testNegateMore {
    g = @"@start = ~Symbol & ~Number;";
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    
    s = @"1";
    res = [lp completeMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDNil(res);

    s = @"$";
    res = [lp completeMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDNil(res);
}    


- (void)testNegateMore2 {
    g = @"@start = ~(Symbol|Number);";
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    
    s = @"1";
    res = [lp completeMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDNil(res);
    
    s = @"$";
    res = [lp completeMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDNil(res);
}


- (void)testNcName {
    g = @"@wordChars=':' '_'; @wordState='_';"
    @"@start = name;"
    @"ncName = name & /[^:]+/;"
    @"name = Word;";
    //        @"nameTest = '*' | ncName ':' '*' | qName;"
    
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    t = lp.tokenizer;
    
    t.string = @"foo";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[foo]foo^", [res description]);
    
    t.string = @"foo:bar";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[foo:bar]foo:bar^", [res description]);
}


- (void)testFunctionName {
    g = 
    @"@wordState = '_';"
    @"@wordChars = '_' '.' '-';"
    @"@start = functionName;"
    @"functionName = qName - nodeType;"
    @"nodeType = 'comment' | 'text' | 'processing-instruction' | 'node';"
    @"qName = prefixedName | unprefixedName;"
    @"prefixedName = prefix ':' localPart;"
    @"unprefixedName = localPart;"
    @"localPart = ncName;"
    @"prefix = ncName;"
    @"ncName = Word;";
    
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    t = lp.tokenizer;
    
    t.string = @"foo";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[foo]foo^", [res description]);
    
    t.string = @"foo:bar";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[foo, :, bar]foo/:/bar^", [res description]);
    
    t.string = @":bar";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDNil(res);
    
    t.string = @"text";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDNil(res);
    
    t.string = @"comment";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDNil(res);
    
    t.string = @"node";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDNil(res);
    
    t.string = @"processing-instruction";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDNil(res);
    
    t.string = @"texts";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[texts]texts^", [res description]);
    
}

@end
