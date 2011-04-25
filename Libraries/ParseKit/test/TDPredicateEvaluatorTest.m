//
//  PKPredicateEvaluatorTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 5/28/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDPredicateEvaluatorTest.h"

@implementation TDPredicateEvaluatorTest

- (id)valueForAttributeKey:(NSString *)key {
    return [d objectForKey:key];
}


- (CGFloat)floatForAttributeKey:(NSString *)key {
    return [(NSNumber *)[d objectForKey:key] floatValue];
}


- (BOOL)boolForAttributeKey:(NSString *)key {
    return [[d objectForKey:key] boolValue];
}


- (void)setUp {
    d = [NSMutableDictionary dictionary];
    p = [[[TDPredicateEvaluator alloc] initWithDelegate:self] autorelease];
}


- (void)testEq {
    // test numbers
    [d setValue:[NSNumber numberWithFloat:1.0] forKey:@"foo"];
    s = @"foo = 1.0";
    a = [p.exprParser bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[1]foo/=/1.0^", [a description]);
    
    s = @"foo = -1.0";
    a = [p.exprParser bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[0]foo/=/-1.0^", [a description]);
    
    
    // test bools
    [d setValue:[NSNumber numberWithBool:YES] forKey:@"foo"];
    s = @"foo = true";
    a = [p.exprParser bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[1]foo/=/true^", [a description]);
    
    s = @"foo = false";
    a = [p.exprParser bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[0]foo/=/false^", [a description]);
    
    [d setValue:[NSNumber numberWithBool:NO] forKey:@"foo"];
    s = @"foo = true";
    a = [p.exprParser bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[0]foo/=/true^", [a description]);
    
    s = @"foo = false";
    a = [p.exprParser bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[1]foo/=/false^", [a description]);
    
    
    // test strings
    [d setValue:@"bar" forKey:@"foo"];
    s = @"foo = 'bar'";
    a = [p.exprParser bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[1]foo/=/'bar'^", [a description]);
    
    s = @"foo = 'baz'";
    a = [p.exprParser bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[0]foo/=/'baz'^", [a description]);
}


- (void)testNe {
    // test numbers
    [d setValue:[NSNumber numberWithFloat:1.0] forKey:@"foo"];
    s = @"foo != 1.0";
    a = [p.exprParser bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[0]foo/!=/1.0^", [a description]);
    
    s = @"foo != -1.0";
    a = [p.exprParser bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[1]foo/!=/-1.0^", [a description]);
    
    
    // test bools
    [d setValue:[NSNumber numberWithBool:YES] forKey:@"foo"];
    s = @"foo != true";
    a = [p.exprParser bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[0]foo/!=/true^", [a description]);
    
    s = @"foo != false";
    a = [p.exprParser bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[1]foo/!=/false^", [a description]);
    
    [d setValue:[NSNumber numberWithBool:NO] forKey:@"foo"];
    s = @"foo != true";
    a = [p.exprParser bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[1]foo/!=/true^", [a description]);
    
    s = @"foo != false";
    a = [p.exprParser bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[0]foo/!=/false^", [a description]);
    
    
    // test strings
    [d setValue:@"bar" forKey:@"foo"];
    s = @"foo != 'bar'";
    a = [p.exprParser bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[0]foo/!=/'bar'^", [a description]);
    
    s = @"foo != 'baz'";
    a = [p.exprParser bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[1]foo/!=/'baz'^", [a description]);
}


- (void)testGt {
    [d setValue:[NSNumber numberWithInteger:41] forKey:@"foo"];
    s = @"foo > 42";
    a = [p.exprParser bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[0]foo/>/42^", [a description]);

    [d setValue:[NSNumber numberWithInteger:43] forKey:@"foo"];
    s = @"foo > 42";
    a = [p.exprParser bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[1]foo/>/42^", [a description]);

    [d setValue:[NSNumber numberWithFloat:1.2] forKey:@"foo"];
    s = @"foo > 1.2";
    a = [p.exprParser bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[0]foo/>/1.2^", [a description]);

    [d setValue:[NSNumber numberWithFloat:1.2001] forKey:@"foo"];
    s = @"foo > 1.2";
    a = [p.exprParser bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[1]foo/>/1.2^", [a description]);
}


- (void)testLt {
    [d setValue:[NSNumber numberWithInteger:41] forKey:@"foo"];
    s = @"foo < .3";
    a = [p.exprParser bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[0]foo/</.3^", [a description]);

    [d setValue:[NSNumber numberWithInteger:0] forKey:@"foo"];
    s = @"foo < .3";
    a = [p.exprParser bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[1]foo/</.3^", [a description]);

    [d setValue:[NSNumber numberWithFloat:.3] forKey:@"foo"];
    s = @"foo < .3";
    a = [p.exprParser bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[0]foo/</.3^", [a description]);

    [d setValue:[NSNumber numberWithFloat:.29999999] forKey:@"foo"];
    s = @"foo < .3";
    a = [p.exprParser bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[1]foo/</.3^", [a description]);
}


- (void)testGteq {
    [d setValue:[NSNumber numberWithInteger:41] forKey:@"foo"];
    s = @"foo >= 42";
    a = [p.exprParser bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[0]foo/>=/42^", [a description]);
    
    [d setValue:[NSNumber numberWithFloat:41.99] forKey:@"foo"];
    s = @"foo >= 42";
    a = [p.exprParser bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[0]foo/>=/42^", [a description]);
    
    [d setValue:[NSNumber numberWithInteger:42] forKey:@"foo"];
    s = @"foo >= 42";
    a = [p.exprParser bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[1]foo/>=/42^", [a description]);
}


- (void)testLteq {
    [d setValue:[NSNumber numberWithInteger:41] forKey:@"foo"];
    s = @"foo <= .3";
    a = [p.exprParser bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[0]foo/<=/.3^", [a description]);

    [d setValue:[NSNumber numberWithFloat:.3] forKey:@"foo"];
    s = @"foo <= .3";
    a = [p.exprParser bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[1]foo/<=/.3^", [a description]);

    [d setValue:[NSNumber numberWithFloat:.3111] forKey:@"foo"];
    s = @"foo <= .3";
    a = [p.exprParser bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[0]foo/<=/.3^", [a description]);
}


- (void)testBeginswith {
    [d setValue:@"foobarbaz" forKey:@"foo"];
    s = @"foo beginswith 'foo'";
    a = [p.exprParser bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[1]foo/beginswith/'foo'^", [a description]);

    [d setValue:@"foobarbaz" forKey:@"foo"];
    s = @"foo beginswith 'bar'";
    a = [p.exprParser bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[0]foo/beginswith/'bar'^", [a description]);
}


- (void)testContains {
    [d setValue:@"foobarbaz" forKey:@"foo"];
    s = @"foo contains 'baz'";
    a = [p.exprParser bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[1]foo/contains/'baz'^", [a description]);

    [d setValue:@"foobarbaz" forKey:@"foo"];
    s = @"foo contains 'bat'";
    a = [p.exprParser bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[0]foo/contains/'bat'^", [a description]);
}


- (void)testEndswith {
    [d setValue:@"foobarbaz" forKey:@"foo"];
    s = @"foo endswith 'baz'";
    a = [p.exprParser bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[1]foo/endswith/'baz'^", [a description]);

    [d setValue:@"foobarbaz" forKey:@"foo"];
    s = @"foo endswith 'bat'";
    a = [p.exprParser bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[0]foo/endswith/'bat'^", [a description]);
}


- (void)testMatches {
    [d setValue:@"foobarbaz" forKey:@"foo"];
    s = @"foo matches 'baz'";
    a = [p.exprParser bestMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[0]foo/matches/'baz'^", [a description]);
}


- (void)testBools {
    s = @"true";
    a = [PKTokenAssembly assemblyWithString:s];
    a = [p.exprParser bestMatchFor:a];
    TDEqualObjects(@"[1]true^", [a description]);
    
    s = @"not true";
    a = [PKTokenAssembly assemblyWithString:s];
    a = [p.exprParser bestMatchFor:a];
    TDEqualObjects(@"[0]not/true^", [a description]);
    
    s = @"false";
    a = [PKTokenAssembly assemblyWithString:s];
    a = [p.exprParser bestMatchFor:a];
    TDEqualObjects(@"[0]false^", [a description]);
    
    s = @"not false";
    a = [PKTokenAssembly assemblyWithString:s];
    a = [p.exprParser bestMatchFor:a];
    TDEqualObjects(@"[1]not/false^", [a description]);
    
    s = @"true and false";
    a = [PKTokenAssembly assemblyWithString:s];
    a = [p.exprParser bestMatchFor:a];
    TDEqualObjects(@"[0]true/and/false^", [a description]);
    
    s = @"not true and false";
    a = [PKTokenAssembly assemblyWithString:s];
    a = [p.exprParser bestMatchFor:a];
    TDEqualObjects(@"[0]not/true/and/false^", [a description]);
    
    s = @"not true and not false";
    a = [PKTokenAssembly assemblyWithString:s];
    a = [p.exprParser bestMatchFor:a];
    TDEqualObjects(@"[0]not/true/and/not/false^", [a description]);
    
    s = @"true or false";
    a = [PKTokenAssembly assemblyWithString:s];
    a = [p.exprParser bestMatchFor:a];
    TDEqualObjects(@"[1]true/or/false^", [a description]);
    
    s = @"(true and false) or false";
    a = [PKTokenAssembly assemblyWithString:s];
    a = [p.exprParser bestMatchFor:a];
    TDEqualObjects(@"[0](/true/and/false/)/or/false^", [a description]);
    
    s = @"(true and false) or not false";
    a = [PKTokenAssembly assemblyWithString:s];
    a = [p.exprParser bestMatchFor:a];
    TDEqualObjects(@"[1](/true/and/false/)/or/not/false^", [a description]);
}

@end
