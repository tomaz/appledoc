//
//  ERBTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/26/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "ERBTest.h"

@interface ERBAssembler : NSObject {
    
}

@end

@implementation ERBAssembler

- (id)provideValueForKey:(NSString *)k {
    return @"hai";
}


- (void)didMatchEndMarker:(PKAssembly *)a {
    [a pop]; // '@>'
    NSString *k = [a pop];
    [a pop]; // discard '<@='
    [a push:[self provideValueForKey:k]];
}


- (void)didMatchDotWord:(PKAssembly *)a {
    PKToken *lastPart = [a pop];
    [a pop]; // '.'
    PKToken *firstPart = [a pop];
    
    NSString *keyPath = [NSString stringWithFormat:@"%@.%@",
                         firstPart, lastPart];
    [a push:keyPath];
    // do something with the keyPath
}

@end


@implementation ERBTest

- (void)setUp {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"erb" ofType:@"grammar"];
    g = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    lp = [[PKParserFactory factory] parserFromGrammar:g assembler:[[[ERBAssembler alloc] init] autorelease]];
    t = lp.tokenizer;
//    startPrintMarker = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"<@=" floatValue:0];
}


- (void)testFoo {
    t.string = @"oh <@= foo.bar @> !";
    res = [lp completeMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
//    TDEqualObjects([res description], @"[oh, hai, !]oh/<@=/foo/./bar/@>/!^");
    
}

@end

