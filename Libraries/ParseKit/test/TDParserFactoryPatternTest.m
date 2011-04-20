//
//  PKParserFactoryPatternTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 6/6/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDParserFactoryPatternTest.h"

@implementation TDParserFactoryPatternTest

- (void)setUp {
    factory = [PKParserFactory factory];
}


- (void)test1 {
    g = @"@start = /foo/;";
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    
    s = @"foo";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[foo]foo^", [res description]);
    
    
    g = @"@start = /fo+/;";
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    
    s = @"foo";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[foo]foo^", [res description]);
    
    
    g = @"@start = /fo+/;";
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    
    s = @"foo";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[foo]foo^", [res description]);
    
    
    g = @"@start = /[fo]+/;";
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    
    s = @"foo";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[foo]foo^", [res description]);
    
        
    g = @"@start = /\\w+/;";
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    
    s = @"foo";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[foo]foo^", [res description]);
}


- (void)testOptions {
    g = @"@start = /foo/i;";
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    
    s = @"FOO";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[FOO]FOO^", [res description]);
    
    
    g = @"@start = /foo/i;";
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    
    s = @"FoO";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[FoO]FoO^", [res description]);
}

@end
