//
//  PKLetterTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/15/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDLetterTest.h"

@interface PKAssembly ()
- (BOOL)hasMore;
@end

@implementation TDLetterTest

- (void)test123 {
    s = @"123";
    a = [PKCharacterAssembly assemblyWithString:s];
    
    TDEqualObjects(@"[]^123", [a description]);
    p = [PKLetter letter];
    
    result = [p bestMatchFor:a];
    TDNotNil(a);
    TDNil(result);
    TDTrue([a hasMore]);
}


- (void)testAbc {
    s = @"abc";
    a = [PKCharacterAssembly assemblyWithString:s];
    
    TDEqualObjects(@"[]^abc", [a description]);
    p = [PKLetter letter];
    
    result = [p bestMatchFor:a];
    TDNotNil(a);
    TDEqualObjects(@"[a]a^bc", [result description]);
    TDTrue([result hasMore]);
}


- (void)testRepetition {
    s = @"abc";
    a = [PKCharacterAssembly assemblyWithString:s];
    
    TDEqualObjects(@"[]^abc", [a description]);
    p = [PKLetter letter];
    PKParser *r = [PKRepetition repetitionWithSubparser:p];
    
    result = [r bestMatchFor:a];
    TDNotNil(a);
    TDEqualObjects(@"[a, b, c]abc^", [result description]);
    TDFalse([result hasMore]);
}

@end
