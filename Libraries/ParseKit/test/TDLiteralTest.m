//
//  PKLiteralTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/13/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDLiteralTest.h"

@implementation TDLiteralTest

- (void)tearDown {
    [a release];
}

- (void)testTrueCompleteMatchForLiteral123 {
    s = @"123";
    a = [[PKTokenAssembly alloc] initWithString:s];
    NSLog(@"a: %@", a);
    
    p = [PKNumber number];
    PKAssembly *result = [p completeMatchFor:a];
    
    // -[PKParser completeMatchFor:]
    // -[PKParser bestMatchFor:]
    // -[PKParser matchAndAssemble:]
    // -[PKTerminal allMatchesFor:]
    // -[PKTerminal matchOneAssembly:]
    // -[PKLiteral qualifies:]
    // -[PKParser best:]
    
    NSLog(@"result: %@", result);
    TDNotNil(result);
    TDEqualObjects(@"[123]123^", [result description]);
}


- (void)testFalseCompleteMatchForLiteral123 {
    s = @"1234";
    a = [[PKTokenAssembly alloc] initWithString:s];
    
    p = [PKLiteral literalWithString:@"123"];
    PKAssembly *result = [p completeMatchFor:a];
    TDNil(result);
    TDEqualObjects(@"[]^1234", [a description]);
}


- (void)testTrueCompleteMatchForLiteralFoo {
    s = @"Foo";
    a = [[PKTokenAssembly alloc] initWithString:s];
    
    p = [PKLiteral literalWithString:@"Foo"];
    PKAssembly *result = [p completeMatchFor:a];
    TDNotNil(result);
    TDEqualObjects(@"[Foo]Foo^", [result description]);
}


- (void)testFalseCompleteMatchForLiteralFoo {
    s = @"Foo";
    a = [[PKTokenAssembly alloc] initWithString:s];
    
    p = [PKLiteral literalWithString:@"foo"];
    PKAssembly *result = [p completeMatchFor:a];
    TDNil(result);
}


- (void)testFalseCompleteMatchForCaseInsensitiveLiteralFoo {
    s = @"Fool";
    a = [[PKTokenAssembly alloc] initWithString:s];
    
    p = [PKCaseInsensitiveLiteral literalWithString:@"Foo"];
    PKAssembly *result = [p completeMatchFor:a];
    TDNil(result);
}


- (void)testTrueCompleteMatchForCaseInsensitiveLiteralFoo {
    s = @"Foo";
    a = [[PKTokenAssembly alloc] initWithString:s];
        
    p = [PKCaseInsensitiveLiteral literalWithString:@"foo"];
    PKAssembly *result = [p completeMatchFor:a];
    TDNotNil(result);
    TDEqualObjects(@"[Foo]Foo^", [result description]);
}

@end
