//
//  PKDigitTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/15/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDDigitTest.h"

@interface PKAssembly ()
- (BOOL)hasMore;
@end

@implementation TDDigitTest

- (void)test123 {
    s = @"123";
    a = [PKCharacterAssembly assemblyWithString:s];
    
    TDEqualObjects(@"[]^123", [a description]);
    p = [PKDigit digit];
    
    result = [p bestMatchFor:a];
    TDNotNil(a);
    TDEqualObjects(@"[1]1^23", [result description]);
    TDTrue([a hasMore]);
}


- (void)testAbc {
    s = @"abc";
    a = [PKCharacterAssembly assemblyWithString:s];
    
    TDEqualObjects(@"[]^abc", [a description]);
    p = [PKDigit digit];
    
    result = [p bestMatchFor:a];
    TDNotNil(a);
    TDNil(result);
    TDTrue([a hasMore]);
}


- (void)testRepetition {
    s = @"123";
    a = [PKCharacterAssembly assemblyWithString:s];
    
    TDEqualObjects(@"[]^123", [a description]);
    p = [PKDigit digit];
    PKParser *r = [PKRepetition repetitionWithSubparser:p];
    
    result = [r bestMatchFor:a];
    TDNotNil(a);
    TDEqualObjects(@"[1, 2, 3]123^", [result description]);
    TDFalse([result hasMore]);
}

@end
