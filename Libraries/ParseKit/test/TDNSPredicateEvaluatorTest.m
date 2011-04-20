//
//  PKNSPredicateEvaluatorTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 6/17/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDNSPredicateEvaluatorTest.h"

@implementation TDNSPredicateEvaluatorTest

- (id)resolvedValueForKeyPath:(NSString *)kp {
    id result = [d objectForKey:kp];
    if (!result) {
        result = [NSNumber numberWithBool:NO];
    }
    return result;
}


- (void)dealloc {
    [eval release];
    [super dealloc];
}


- (void)setUp {
    d = [NSMutableDictionary dictionary];
    eval = [[TDNSPredicateEvaluator alloc] initWithKeyPathResolver:self];
    t = eval.parser.tokenizer;
}


- (void)testKeyPath {
    [d setObject:[NSNumber numberWithBool:YES] forKey:@"foo"];
    [d setObject:[NSNumber numberWithBool:NO] forKey:@"baz"];
    
    t.string = @"foo";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [[eval.parser parserNamed:@"keyPath"] completeMatchFor:a];
    TDEqualObjects(@"[1]foo^", [res description]);

    t.string = @"bar";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [[eval.parser parserNamed:@"keyPath"] completeMatchFor:a];
    TDEqualObjects(@"[0]bar^", [res description]);

    t.string = @"baz";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [[eval.parser parserNamed:@"keyPath"] completeMatchFor:a];
    TDEqualObjects(@"[0]baz^", [res description]);

    t.string = @"foo.bar";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [[eval.parser parserNamed:@"keyPath"] completeMatchFor:a];
    TDEqualObjects(@"[0]foo.bar^", [res description]);
}    


- (void)testNegatedPredicate {
    t.string = @"not 0 < 2";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [eval.parser completeMatchFor:a];
    TDEqualObjects(@"[0]not/0/</2^", [res description]);

    t.string = @"! 0 < 2";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [eval.parser completeMatchFor:a];
    TDEqualObjects(@"[0]!/0/</2^", [res description]);
}


- (void)testStringTest {
    t.string = @"'foo' BEGINSWITH 'f'";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [eval.parser completeMatchFor:a];
    TDEqualObjects(@"[1]'foo'/BEGINSWITH/'f'^", [res description]);

    t.string = @"'foo' BEGINSWITH 'o'";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [eval.parser completeMatchFor:a];
    TDEqualObjects(@"[0]'foo'/BEGINSWITH/'o'^", [res description]);

    t.string = @"'foo' ENDSWITH 'f'";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [eval.parser completeMatchFor:a];
    TDEqualObjects(@"[0]'foo'/ENDSWITH/'f'^", [res description]);
    
    t.string = @"'foo' ENDSWITH 'o'";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [eval.parser completeMatchFor:a];
    TDEqualObjects(@"[1]'foo'/ENDSWITH/'o'^", [res description]);

    t.string = @"'foo' CONTAINS 'fo'";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [eval.parser completeMatchFor:a];
    TDEqualObjects(@"[1]'foo'/CONTAINS/'fo'^", [res description]);
    
    t.string = @"'foo' CONTAINS '-'";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [eval.parser completeMatchFor:a];
    TDEqualObjects(@"[0]'foo'/CONTAINS/'-'^", [res description]);
}

    
- (void)testComparison {
    t.string = @"1 < 2";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [eval.parser completeMatchFor:a];
    TDEqualObjects(@"[1]1/</2^", [res description]);

    t.string = @"1 > 2";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [eval.parser completeMatchFor:a];
    TDEqualObjects(@"[0]1/>/2^", [res description]);
    
    t.string = @"1 != 2";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [eval.parser completeMatchFor:a];
    TDEqualObjects(@"[1]1/!=/2^", [res description]);
    
    t.string = @"1 == 2";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [eval.parser completeMatchFor:a];
    TDEqualObjects(@"[0]1/==/2^", [res description]);

    t.string = @"1 = 2";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [eval.parser completeMatchFor:a];
    TDEqualObjects(@"[0]1/=/2^", [res description]);
}


- (void)testArray {
    t.string = @"{1, 3}";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    
    res = [[eval.parser parserNamed:@"array"] completeMatchFor:a];
    NSArray *array = [res pop];
    TDEquals((NSUInteger)2, [array count]);
    TDEqualObjects([array objectAtIndex:0], [NSNumber numberWithInteger:1]);
    TDEqualObjects([array objectAtIndex:1], [NSNumber numberWithInteger:3]);
}


- (void)testTrue {
    t.string = @"true";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    
    res = [[eval.parser parserNamed:@"bool"] completeMatchFor:a];
    TDEqualObjects(@"[1]true^", [res description]);
}


- (void)testFalse {
    t.string = @"false";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    
    res = [[eval.parser parserNamed:@"bool"] completeMatchFor:a];
    TDEqualObjects(@"[0]false^", [res description]);
}


- (void)testTruePredicate {
    t.string = @"TRUEPREDICATE";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    
    res = [eval.parser completeMatchFor:a];
    TDEqualObjects(@"[1]TRUEPREDICATE^", [res description]);
}


- (void)testFalsePredicate {
    t.string = @"FALSEPREDICATE";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    
    res = [eval.parser completeMatchFor:a];
    TDEqualObjects(@"[0]FALSEPREDICATE^", [res description]);
}


- (void)testCollectionTest {
    t.string = @"1 IN {1}";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    
    res = [eval.parser completeMatchFor:a];
    TDEqualObjects(@"[1]1/IN/{/1/}^", [res description]);
}    


- (void)testCollectionLtComparison {
    t.string = @"ANY {3} < 4";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    
    res = [eval.parser completeMatchFor:a];
    TDEqualObjects(@"[1]ANY/{/3/}/</4^", [res description]);
    
    t.string = @"SOME {3} < 4";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    
    res = [eval.parser completeMatchFor:a];
    TDEqualObjects(@"[1]SOME/{/3/}/</4^", [res description]);
    
    t.string = @"NONE {3} < 4";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    
    res = [eval.parser completeMatchFor:a];
    TDEqualObjects(@"[0]NONE/{/3/}/</4^", [res description]);
    
    t.string = @"ALL {3} < 4";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    
    res = [eval.parser completeMatchFor:a];
    TDEqualObjects(@"[1]ALL/{/3/}/</4^", [res description]);
}    


- (void)testCollectionGtComparison {
    t.string = @"ANY {3} > 4";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    
    res = [eval.parser completeMatchFor:a];
    TDEqualObjects(@"[0]ANY/{/3/}/>/4^", [res description]);
    
    t.string = @"SOME {3} > 4";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    
    res = [eval.parser completeMatchFor:a];
    TDEqualObjects(@"[0]SOME/{/3/}/>/4^", [res description]);
    
    t.string = @"NONE {3} > 4";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    
    res = [eval.parser completeMatchFor:a];
    TDEqualObjects(@"[1]NONE/{/3/}/>/4^", [res description]);
    
    t.string = @"ALL {3} > 4";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    
    res = [eval.parser completeMatchFor:a];
    TDEqualObjects(@"[0]ALL/{/3/}/>/4^", [res description]);
}    


- (void)testOr {
    t.string = @"TRUEPREDICATE OR FALSEPREDICATE";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    
    res = [eval.parser completeMatchFor:a];
    TDEqualObjects(@"[1]TRUEPREDICATE/OR/FALSEPREDICATE^", [res description]);
}    


- (void)testAnd {
    t.string = @"TRUEPREDICATE AND FALSEPREDICATE";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    
    res = [eval.parser completeMatchFor:a];
    TDEqualObjects(@"[0]TRUEPREDICATE/AND/FALSEPREDICATE^", [res description]);
}    


- (void)testCompoundExpr {
    t.string = @"(TRUEPREDICATE)";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    
    res = [eval.parser completeMatchFor:a];
    TDEqualObjects(@"[1](/TRUEPREDICATE/)^", [res description]);
}    

@end
