//
//  PKSpecificCharTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/15/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDSpecificCharTest.h"

@interface PKAssembly ()
- (BOOL)hasMore;
@end

@implementation TDSpecificCharTest

- (void)test123 {
    s = @"123";
    a = [PKCharacterAssembly assemblyWithString:s];
    
    TDEqualObjects(@"[]^123", [a description]);
    p = [PKSpecificChar specificCharWithChar:'1'];
    
    result = [p bestMatchFor:a];
    TDNotNil(a);
    TDEqualObjects(@"[1]1^23", [result description]);
    TDTrue([a hasMore]);
}


- (void)testAbc {
    s = @"abc";
    a = [PKCharacterAssembly assemblyWithString:s];
    
    TDEqualObjects(@"[]^abc", [a description]);
    p = [PKSpecificChar specificCharWithChar:'1'];
    
    result = [p bestMatchFor:a];
    TDNotNil(a);
    TDNil(result);
    TDTrue([a hasMore]);
}


- (void)testRepetition {
    s = @"aaa";
    a = [PKCharacterAssembly assemblyWithString:s];
    
    TDEqualObjects(@"[]^aaa", [a description]);
    p = [PKSpecificChar specificCharWithChar:'a'];
    PKParser *r = [PKRepetition repetitionWithSubparser:p];
    
    result = [r bestMatchFor:a];
    TDNotNil(a);
    TDEqualObjects(@"[a, a, a]aaa^", [result description]);
    TDFalse([result hasMore]);
}

@end
