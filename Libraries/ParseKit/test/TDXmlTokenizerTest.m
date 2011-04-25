//
//  PKXmlTokenizerTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/21/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDXmlTokenizerTest.h"
#import "TDXmlDecl.h"
#import "TDXmlStartTag.h"
#import "TDXmlEndTag.h"
#import "TDXmlText.h"
#import "TDXmlSignificantWhitespace.h"
#import "TDXmlTokenAssembly.h"


@implementation TDXmlTokenizerTest

- (void)testFoo {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"apple-boss" ofType:@"xml"];

    TDXmlTokenizer *t = [TDXmlTokenizer tokenizerWithContentsOfFile:path];
    NSLog(@"\n\n %@\n\n", t);
    
    TDXmlToken *eof = [TDXmlToken EOFToken];
    TDXmlToken *tok = nil;
    
    while ((tok = [t nextToken]) != eof) {
        //NSLog(@" %@", [tok debugDescription]);
    }
}


- (void)testAppleBoss {
    PKSequence *s = [PKSequence sequence];
    s.name = @"parent sequence";
    [s add:[TDXmlStartTag startTagWithString:@"result"]];
    [s add:[TDXmlStartTag startTagWithString:@"url"]];
    [s add:[TDXmlText text]];
    [s add:[TDXmlEndTag endTagWithString:@"url"]];
    [s add:[TDXmlEndTag endTagWithString:@"result"]];
    
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"small-xml-file" ofType:@"xml"];
    TDXmlTokenAssembly *a = [TDXmlTokenAssembly assemblyWithString:path];
    
    PKAssembly *result = [s bestMatchFor:a];
    NSLog(@"\n\n\n result: %@ \n\n\n", result);
}

@end
