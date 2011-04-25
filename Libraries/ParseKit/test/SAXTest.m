//
//  SAXTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/17/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "SAXTest.h"

@implementation SAXTest

- (void)setUp {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"xml" ofType:@"grammar"];
    g = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    factory = [PKParserFactory factory];
    p = [factory parserFromGrammar:g assembler:self];
    t = p.tokenizer;
}


- (void)testSTag {
    //PKParser *sTag = [p parserNamed:@"sTag"];

}

@end
