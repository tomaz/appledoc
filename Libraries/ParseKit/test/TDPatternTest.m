//
//  PKPatternTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 5/31/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDPatternTest.h"

@implementation TDPatternTest

- (void)testFoo {
    s = @"foo";
    a = [PKTokenAssembly assemblyWithString:s];
    p = [PKPattern patternWithString:@"foo"];
    a = [p completeMatchFor:a];
    
    TDNotNil(a);
    TDEqualObjects([a description], @"[foo]foo^");

    s = @"foo";
    a = [PKTokenAssembly assemblyWithString:s];
    p = [PKPattern patternWithString:@"foo"];
    a = [p completeMatchFor:a];
    
    TDNotNil(a);
    TDEqualObjects([a description], @"[foo]foo^");
    
    s = @"foo";
    a = [PKTokenAssembly assemblyWithString:s];
    p = [PKPattern patternWithString:@"foo"];

    inter = [PKIntersection intersection];
    [inter add:p];
    [inter add:[PKWord word]];

    a = [inter completeMatchFor:a];
    
    TDNotNil(a);
    TDEqualObjects([a description], @"[foo]foo^");
        
    s = @"foo";
    a = [PKTokenAssembly assemblyWithString:s];
    p = [PKPattern patternWithString:@"foo"];

    inter = [PKIntersection intersection];
    [inter add:p];
    [inter add:[PKSymbol symbol]];

    a = [inter completeMatchFor:a];
    
    TDNil(a);
    
    s = @"foo";
    a = [PKTokenAssembly assemblyWithString:s];
    p = [PKPattern patternWithString:@"fo+"];
    a = [p completeMatchFor:a];
    
    TDNotNil(a);
    TDEqualObjects([a description], @"[foo]foo^");

    s = @"foo";
    a = [PKTokenAssembly assemblyWithString:s];
    p = [PKPattern patternWithString:@"fo*"];
    a = [p completeMatchFor:a];

    TDNotNil(a);
    TDEqualObjects([a description], @"[foo]foo^");

    s = @"foo";
    a = [PKTokenAssembly assemblyWithString:s];
    p = [PKPattern patternWithString:@"fo{1,2}"];
    a = [p completeMatchFor:a];
    
    TDNotNil(a);
    TDEqualObjects([a description], @"[foo]foo^");

    s = @"foo";
    a = [PKTokenAssembly assemblyWithString:s];
    p = [PKPattern patternWithString:@"fo{3,4}"];
    a = [p completeMatchFor:a];
    
    TDNil(a);
}


- (void)testSlashFooSlash {
    s = @"/foo/";

    t = [PKTokenizer tokenizerWithString:s];
    [t setTokenizerState:t.quoteState from:'/' to:'/'];
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    p = [PKPattern patternWithString:@"/foo/" options:PKPatternOptionsNone];
    
    inter = [PKIntersection intersection];
    [inter add:p];
    [inter add:[PKQuotedString quotedString]];

    a = [inter completeMatchFor:a];
    
    TDNotNil(a);
    TDEqualObjects([a description], @"[/foo/]/foo/^");

    t = [PKTokenizer tokenizerWithString:s];
    [t setTokenizerState:t.quoteState from:'/' to:'/'];
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    p = [PKPattern patternWithString:@"/[^/]+/" options:PKPatternOptionsNone];

    inter = [PKIntersection intersection];
    [inter add:p];
    [inter add:[PKQuotedString quotedString]];
    
    a = [inter completeMatchFor:a];
    
    TDNotNil(a);
    TDEqualObjects([a description], @"[/foo/]/foo/^");
}


- (void)testAndOrOr {
    s = @"and";
    a = [PKTokenAssembly assemblyWithString:s];
    p = [PKPattern patternWithString:@"and|or"];
    a = [p completeMatchFor:a];
    
    TDNotNil(a);
    TDEqualObjects([a description], @"[and]and^");
    
    s = @"and";
    a = [PKTokenAssembly assemblyWithString:s];
    p = [PKPattern patternWithString:@"an|or"];
    a = [p completeMatchFor:a];
    
    TDNil(a);
    
    s = @"or";
    a = [PKTokenAssembly assemblyWithString:s];
    p = [PKPattern patternWithString:@"(and)|(or)"];
    a = [p completeMatchFor:a];
    
    TDNotNil(a);
    TDEqualObjects([a description], @"[or]or^");
}    


- (void)testNotAnd {
    s = @"foo";
    a = [PKTokenAssembly assemblyWithString:s];
    p = [PKPattern patternWithString:@"[^and]+"];
    a = [p completeMatchFor:a];
    
    TDNotNil(a);
    TDEqualObjects([a description], @"[foo]foo^");
    
    s = @"and";
    a = [PKTokenAssembly assemblyWithString:s];
    p = [PKPattern patternWithString:@"[^(and)]"];
    a = [p completeMatchFor:a];
    
    TDNil(a);
}    


- (void)testInvertFoo {
    s = @"foo";
    a = [PKTokenAssembly assemblyWithString:s];
    p = [PKPattern patternWithString:@"fo+"];
    a = [p completeMatchFor:a];
    
    TDNotNil(a);
    TDEqualObjects([a description], @"[foo]foo^");
    
    p = [PKNegation negationWithSubparser:p];
    a = [p completeMatchFor:a];
    
    TDNil(a);
}    


- (void)testInvertAndOrNotTrueFalse {
    s = @"true";
    a = [PKTokenAssembly assemblyWithString:s];
    p = [PKPattern patternWithString:@"and|or|not|true|false"];
    a = [p completeMatchFor:a];
    
    TDNotNil(a);
    TDEqualObjects([a description], @"[true]true^");
    
    p = [PKNegation negationWithSubparser:p];
    a = [p completeMatchFor:a];
    
    TDNil(a);

    s = @"TRUE";
    a = [PKTokenAssembly assemblyWithString:s];
    p = [PKPattern patternWithString:@"and|or|not|true|false" options:PKPatternOptionsIgnoreCase];
    a = [p completeMatchFor:a];
    
    TDNotNil(a);
    TDEqualObjects([a description], @"[TRUE]TRUE^");
    
    p = [PKNegation negationWithSubparser:p];
    a = [p completeMatchFor:a];
    
    TDNil(a);

    s = @"NOT";
    a = [PKTokenAssembly assemblyWithString:s];
    p = [PKPattern patternWithString:@"and|or|not|true|false" options:PKPatternOptionsIgnoreCase];

    inter = [PKIntersection intersection];
    [inter add:p];
    [inter add:[PKWord word]];
    
    a = [inter completeMatchFor:a];
    
    TDNotNil(a);
    TDEqualObjects([a description], @"[NOT]NOT^");
    
    p = [PKNegation negationWithSubparser:p];
    a = [p completeMatchFor:a];
    
    TDNil(a);

    s = @"oR";
    a = [PKTokenAssembly assemblyWithString:s];
    p = [PKPattern patternWithString:@"and|or|not|true|false" options:PKPatternOptionsIgnoreCase];
    
    inter = [PKIntersection intersection];
    [inter add:p];
    [inter add:[PKSymbol symbol]];
    
    a = [inter completeMatchFor:a];
    
    TDNil(a);
}    

@end
