//
//  TDExclusionTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/2/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDExclusionTest.h"

@implementation TDExclusionTest

- (void)testFoo {
    PKExclusion *ex = [PKExclusion exclusion];
    [ex add:[PKWord word]];
    [ex add:[PKNum num]];
    
    s = @"'foo'";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [ex bestMatchFor:a];
    TDNil(res);
    
    s = @"$";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [ex bestMatchFor:a];
    TDNil(res);
    
    s = @"foo";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [ex bestMatchFor:a];
    TDEqualObjects(@"[foo]foo^", [res description]);
    
    s = @"2";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [ex bestMatchFor:a];
    TDEqualObjects(@"[2]2^", [res description]);
}

@end
