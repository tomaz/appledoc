//
//  PKMinusTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 6/26/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDDifferenceTest.h"

@implementation TDDifferenceTest

- (void)testFoo {
    PKWord *word = [PKWord word];
    PKLiteral *foo = [PKLiteral literalWithString:@"foo"];
    d = [PKDifference differenceWithSubparser:word minus:foo];
    
    s = @"bar";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [d bestMatchFor:a];
    TDEqualObjects(@"[bar]bar^", [res description]);
    
    s = @"foo";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [d bestMatchFor:a];
    NSLog(@"res: %@", res);
    TDNil(res);

    s = @"wee";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [d bestMatchFor:a];
    TDEqualObjects(@"[wee]wee^", [res description]);
}


- (void)testAlt {
    PKWord *word = [PKWord word];
    PKAlternation *list = [PKAlternation alternation];
    [list add:[PKLiteral literalWithString:@"foo"]];
    [list add:[PKLiteral literalWithString:@"bar"]];
    
    d = [PKDifference differenceWithSubparser:word minus:list];
    
    s = @"baz";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [d bestMatchFor:a];
    TDEqualObjects(@"[baz]baz^", [res description]);
    
    s = @"foo";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [d bestMatchFor:a];
    TDNil(res);
    
    s = @"bar";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [d bestMatchFor:a];
    TDNil(res);
    
    s = @"%";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [d bestMatchFor:a];
    TDNil(res);
    
    s = @"wee";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [d bestMatchFor:a];
    TDEqualObjects(@"[wee]wee^", [res description]);
}


- (void)testAlt2 {
    PKAlternation *ok = [PKAlternation alternation];
    [ok add:[PKLiteral literalWithString:@"foo"]];
    [ok add:[PKLiteral literalWithString:@"baz"]];
    
    PKAlternation *list = [PKAlternation alternation];
    [list add:[PKLiteral literalWithString:@"foo"]];
    [list add:[PKLiteral literalWithString:@"bar"]];
    
    d = [PKDifference differenceWithSubparser:ok minus:list];
    
    s = @"baz";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [d bestMatchFor:a];
    TDEqualObjects(@"[baz]baz^", [res description]);
    
    s = @"foo";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [d bestMatchFor:a];
    TDNil(res);

    s = @"wee";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [d bestMatchFor:a];
    TDNil(res);
}


- (void)testParserNamed {
    PKWord *w = [PKWord word];
    w.name = @"w";

    PKCollectionParser *m = [PKAlternation alternation];
    m.name = @"m";
    
    PKParser *foo = [PKLiteral literalWithString:@"foo"];
    foo.name = @"foo";
    [m add:foo];

    PKParser *bar = [PKLiteral literalWithString:@"bar"];
    bar.name = @"bar";
    [m add:bar];
    
    d = [PKDifference differenceWithSubparser:w minus:m];
    
    TDEquals(w, [d parserNamed:@"w"]);
    TDEquals(m, [d parserNamed:@"m"]);
    TDEquals(foo, [d parserNamed:@"foo"]);
    TDEquals(bar, [d parserNamed:@"bar"]);
}

@end
