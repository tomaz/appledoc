//
//  TDNegationTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/2/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDNegationTest.h"

@implementation TDNegationTest

- (void)testFoo {
    n = [PKNegation negationWithSubparser:[PKWord word]];
    
    s = @"bar";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [n bestMatchFor:a];
    TDNil(res);

    s = @"'foo'";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [n bestMatchFor:a];
    TDEqualObjects(@"['foo']'foo'^", [res description]);

    n = [PKNegation negationWithSubparser:[PKLiteral literalWithString:@"foo"]];
    
    s = @"foo";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [n bestMatchFor:a];
    TDNil(res);
}


- (void)testParserNamed {
    PKWord *w = [PKWord word];
    w.name = @"w";
    n = [PKNegation negationWithSubparser:w];
    
    TDEquals(w, [n parserNamed:@"w"]);

    PKCollectionParser *alt = [PKAlternation alternation];
    alt.name = @"alt";
    
    PKParser *foo = [PKLiteral literalWithString:@"foo"];
    foo.name = @"foo";
    [alt add:foo];
    
    PKParser *bar = [PKLiteral literalWithString:@"bar"];
    bar.name = @"bar";
    [alt add:bar];
    
    n = [PKNegation negationWithSubparser:alt];
    
    TDEquals(alt, [n parserNamed:@"alt"]);
    TDEquals(foo, [n parserNamed:@"foo"]);
    TDEquals(bar, [n parserNamed:@"bar"]);
}
    
@end
