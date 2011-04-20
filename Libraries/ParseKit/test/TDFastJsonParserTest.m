//
//  PKFastJsonParserTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/14/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDFastJsonParserTest.h"
#import "TDFastJsonParser.h"

@implementation TDFastJsonParserTest

- (void)testRun {
    NSString *s = @"{\"foo\":\"bar\"}";
    TDFastJsonParser *p = [[[TDFastJsonParser alloc] init] autorelease];
    id result = [p parse:s];
    
    NSLog(@"result");
    TDNotNil(result);
}


- (void)testCrunchBaseJsonParser {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"yahoo" ofType:@"json"];
    NSString *s = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    TDFastJsonParser *parser = [[[TDFastJsonParser alloc] init] autorelease];
    [parser parse:s];
    //    id res = [parser parse:s];
    //NSLog(@"res %@", res);
}

@end
