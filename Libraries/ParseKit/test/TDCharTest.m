//
//  PKCharTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/15/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDCharTest.h"

@interface PKAssembly ()
- (BOOL)hasMore;
@end

@implementation TDCharTest

- (void)test123 {
    s = @"123";
    a = [PKCharacterAssembly assemblyWithString:s];
    
    TDEqualObjects(@"[]^123", [a description]);
    p = [PKChar char];
    
    result = [p bestMatchFor:a];
    TDNotNil(a);
    TDEqualObjects(@"[1]1^23", [result description]);
    TDTrue([a hasMore]);
}


- (void)testAbc {
    s = @"abc";
    a = [PKCharacterAssembly assemblyWithString:s];
    
    TDEqualObjects(@"[]^abc", [a description]);
    p = [PKChar char];
    
    result = [p bestMatchFor:a];
    TDNotNil(a);
    TDEqualObjects(@"[a]a^bc", [result description]);
    TDTrue([a hasMore]);
}

- (void)testRepetition {
    s = @"abc";
    a = [PKCharacterAssembly assemblyWithString:s];
    
    TDEqualObjects(@"[]^abc", [a description]);
    p = [PKChar char];
    PKParser *r = [PKRepetition repetitionWithSubparser:p];
    
    result = [r bestMatchFor:a];
    TDNotNil(a);
    TDEqualObjects(@"[a, b, c]abc^", [result description]);
    TDFalse([result hasMore]);
}


@end
