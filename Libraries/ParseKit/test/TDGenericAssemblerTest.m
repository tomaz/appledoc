//
//  PKGenericAssemblerTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 12/25/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDGenericAssemblerTest.h"

@implementation TDGenericAssemblerTest

- (void)setUp {
    path = [[NSBundle bundleForClass:[self class]] pathForResource:@"mini_css" ofType:@"grammar"];
    grammarString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    cssAssember = [[TDMiniCSSAssembler alloc] init];
    factory = [PKParserFactory factory];
    cssParser = [factory parserFromGrammar:grammarString assembler:cssAssember];
}


- (void)tearDown {
    [cssAssember release];
}


- (void)testColor {
    TDNotNil(cssParser);
    
    path = [[NSBundle bundleForClass:[self class]] pathForResource:@"json" ofType:@"css"];
    s = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    a = [PKTokenAssembly assemblyWithString:s];
    a = [cssParser bestMatchFor:a];
    
    TDNotNil(cssAssember.attributes);
    id props = [cssAssember.attributes objectForKey:@"openCurly"];
    TDNotNil(props);

//    color:red;
//    background-color:blue;
//    font-family:'Helvetica';
//    font-size:17px;
    
    NSFont *font = [props objectForKey:NSFontAttributeName];
    TDNotNil(font);
    TDEqualObjects([font familyName], @"Monaco");
    TDEquals((CGFloat)[font pointSize], (CGFloat)11.0);
    
    NSColor *bgColor = [props objectForKey:NSBackgroundColorAttributeName];
    TDNotNil(bgColor);
    STAssertEqualsWithAccuracy([bgColor redComponent], (CGFloat)0.117, 0.001, @"");
    STAssertEqualsWithAccuracy([bgColor greenComponent], (CGFloat)0.117, 0.001, @"");
    STAssertEqualsWithAccuracy([bgColor blueComponent], (CGFloat)0.141, 0.001, @"");
    
    NSColor *color = [props objectForKey:NSForegroundColorAttributeName];
    TDNotNil(color);
    STAssertEqualsWithAccuracy([color redComponent], (CGFloat)0.7, 0.001, @"");
    STAssertEqualsWithAccuracy([color greenComponent], (CGFloat)0.14, 0.001, @"");
    STAssertEqualsWithAccuracy([color blueComponent], (CGFloat)0.530, 0.001, @"");
    
}




@end
