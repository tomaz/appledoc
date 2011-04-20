//
//  PKTokenAssemblyTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/13/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDTokenAssemblyTest.h"

@interface PKAssembly ()
- (id)next;
- (BOOL)hasMore;
@property (nonatomic, readonly) NSUInteger length;
@property (nonatomic, readonly) NSUInteger objectsConsumed;
@property (nonatomic, readonly) NSUInteger objectsRemaining;
@end

@implementation TDTokenAssemblyTest

- (void)setUp {
}


- (void)tearDown {
    [p release];
}


#pragma mark -

- (void)testWordOhSpaceHaiExclamation {
    s = @"oh hai!";
    a = [PKTokenAssembly assemblyWithString:s];

    TDEquals((NSUInteger)3, [a length]);

    TDEquals((NSUInteger)0, a.objectsConsumed);
    TDEquals((NSUInteger)3, a.objectsRemaining);
    TDEqualObjects(@"[]^oh/hai/!", [a description]);
    TDTrue([a hasMore]);
    TDEqualObjects(@"oh", [[a next] stringValue]);

    TDEquals((NSUInteger)1, a.objectsConsumed);
    TDEquals((NSUInteger)2, a.objectsRemaining);
    TDEqualObjects(@"[]oh^hai/!", [a description]);
    TDTrue([a hasMore]);
    TDEqualObjects(@"hai", [[a next] stringValue]);

    TDEquals((NSUInteger)2, a.objectsConsumed);
    TDEquals((NSUInteger)1, a.objectsRemaining);
    TDEqualObjects(@"[]oh/hai^!", [a description]);
    TDTrue([a hasMore]);
    TDEqualObjects(@"!", [[a next] stringValue]);

    TDEquals((NSUInteger)3, a.objectsConsumed);
    TDEquals((NSUInteger)0, a.objectsRemaining);
    TDEqualObjects(@"[]oh/hai/!^", [a description]);
    TDFalse([a hasMore]);
    TDNil([[a next] stringValue]);

    TDEquals((NSUInteger)3, a.objectsConsumed);
    TDEquals((NSUInteger)0, a.objectsRemaining);
    TDEqualObjects(@"[]oh/hai/!^", [a description]);
    TDFalse([a hasMore]);
    TDNil([[a next] stringValue]);

    TDEquals((NSUInteger)3, [a length]);
}


- (void)testBestMatchForWordFoobar {
    s = @"foobar";
    a = [PKTokenAssembly assemblyWithString:s];

    TDEquals((NSUInteger)1, [a length]);
    TDEqualObjects(@"[]^foobar", [a description]);
    
    p = [[PKWord alloc] init];
    PKAssembly *result = [p bestMatchFor:a];
    TDEqualObjects(@"[foobar]foobar^", [result description]);
    TDFalse(result == a);


    result = [p bestMatchFor:result];
    TDNil(result);
}


- (void)testCompleteMatchForWordFoobar {
    s = @"foobar";
    a = [PKTokenAssembly assemblyWithString:s];
    
    TDEquals((NSUInteger)1, [a length]);
    TDEqualObjects(@"[]^foobar", [a description]);
    
    p = [[PKWord alloc] init];
    PKAssembly *result = [p completeMatchFor:a];
    TDEqualObjects(@"[foobar]foobar^", [result description]);
    TDFalse(result == a);
}


- (void)testBestMatchForWordFooSpaceBar {
    s = @"foo bar";
    a = [PKTokenAssembly assemblyWithString:s];
    
    TDEquals((NSUInteger)2, [a length]);
    TDEqualObjects(@"[]^foo/bar", [a description]);
    
    p = [[PKWord alloc] init];
    PKAssembly *result = [p bestMatchFor:a];
    TDEqualObjects(@"[foo]foo^bar", [result description]);
    TDFalse(result == a);
}


- (void)testCompleteMatchForWordFooSpaceBar {
    s = @"foo bar";
    a = [PKTokenAssembly assemblyWithString:s];
    
    TDEquals((NSUInteger)2, [a length]);
    TDEqualObjects(@"[]^foo/bar", [a description]);
    
    p = [[PKWord alloc] init];
    PKAssembly *result = [p completeMatchFor:a];
    TDNil(result);
}


- (void)testBestMatchForNumFoobar {
    s = @"foobar";
    a = [PKTokenAssembly assemblyWithString:s];
    
    TDEquals((NSUInteger)1, [a length]);
    TDEqualObjects(@"[]^foobar", [a description]);
    
    p = [[PKNumber alloc] init];
    PKAssembly *result = [p bestMatchFor:a];
    TDNil(result);
}


- (void)testCompleteMatchForNumFoobar {
    s = @"foobar";
    a = [PKTokenAssembly assemblyWithString:s];
    
    TDEquals((NSUInteger)1, [a length]);
    TDEqualObjects(@"[]^foobar", [a description]);
    
    p = [[PKNumber alloc] init];
    PKAssembly *result = [p completeMatchFor:a];
    TDNil(result);
}


- (void)testBestMatchForWord123 {
    s = @"123";
    a = [PKTokenAssembly assemblyWithString:s];
    
    TDEquals((NSUInteger)1, [a length]);
    TDEqualObjects(@"[]^123", [a description]);
    
    p = [[PKWord alloc] init];
    PKAssembly *result = [p bestMatchFor:a];
    TDNil(result);
}


- (void)testCompleteMatchForWord123 {
    s = @"123";
    a = [PKTokenAssembly assemblyWithString:s];
    
    
    p = [[PKWord alloc] init];
    PKAssembly *result = [p completeMatchFor:a];
    TDNil(result);
    TDEquals((NSUInteger)1, [a length]);
    TDEqualObjects(@"[]^123", [a description]);
}


- (void)testBestMatchForNum123 {
    s = @"123";
    a = [PKTokenAssembly assemblyWithString:s];
    
    TDEquals((NSUInteger)1, [a length]);
    TDEqualObjects(@"[]^123", [a description]);
    
    p = [[PKNumber alloc] init];
    PKAssembly *result = [p bestMatchFor:a];
    TDEqualObjects(@"[123]123^", [result description]);
    TDFalse(result == a);
}


- (void)testCompleteMatchForNum123 {
    s = @"123";
    a = [PKTokenAssembly assemblyWithString:s];
    
    TDEquals((NSUInteger)1, [a length]);
    TDEqualObjects(@"[]^123", [a description]);
    
    p = [[PKNumber alloc] init];
    PKAssembly *result = [p bestMatchFor:a];
    TDEqualObjects(@"[123]123^", [result description]);
    TDFalse(result == a);
}


- (void)testBestMatchForNum123Space456 {
    s = @"123 456";
    a = [PKTokenAssembly assemblyWithString:s];
    
    TDEquals((NSUInteger)2, [a length]);
    TDEqualObjects(@"[]^123/456", [a description]);
    
    p = [[PKNumber alloc] init];
    PKAssembly *result = [p bestMatchFor:a];
    TDEqualObjects(@"[123]123^456", [result description]);
    TDFalse(result == a);
}


- (void)testCompleteMatchForNum123Space456 {
    s = @"123 456";
    a = [PKTokenAssembly assemblyWithString:s];
    
    TDEquals((NSUInteger)2, [a length]);
    TDEqualObjects(@"[]^123/456", [a description]);
    
    p = [[PKNumber alloc] init];
    PKAssembly *result = [p completeMatchFor:a];
    TDNil(result);
}


- (void)testBestMatchForWordFoobarSpace123 {
    s = @"foobar 123";
    a = [PKTokenAssembly assemblyWithString:s];
    
    TDEquals((NSUInteger)2, [a length]);
    TDEqualObjects(@"[]^foobar/123", [a description]);
    
    p = [[PKWord alloc] init];
    PKAssembly *result = [p bestMatchFor:a];
    TDEqualObjects(@"[foobar]foobar^123", [result description]);
    TDFalse(result == a);
}


- (void)testCompleteMatchForWordFoobarSpace123 {
    s = @"foobar 123";
    a = [PKTokenAssembly assemblyWithString:s];
    
    TDEquals((NSUInteger)2, [a length]);
    TDEqualObjects(@"[]^foobar/123", [a description]);
    
    p = [[PKWord alloc] init];
    PKAssembly *result = [p completeMatchFor:a];
    TDNil(result);
}


- (void)testBestMatchForNum123Space456Foobar {
    s = @"123 456 foobar";
    a = [PKTokenAssembly assemblyWithString:s];

    TDEquals((NSUInteger)3, [a length]);
    TDEqualObjects(@"[]^123/456/foobar", [a description]);
    
    p = [[PKNumber alloc] init];
    PKAssembly *result = [p bestMatchFor:a];
    TDEqualObjects(@"[123]123^456/foobar", [result description]);
    TDFalse(result == a);
}


- (void)testCompleteMatchForNum123Space456Foobar {
    s = @"123 456 foobar";
    a = [PKTokenAssembly assemblyWithString:s];
    
    TDEquals((NSUInteger)3, [a length]);
    TDEqualObjects(@"[]^123/456/foobar", [a description]);
    
    p = [[PKNumber alloc] init];
    PKAssembly *result = [p completeMatchFor:a];
    TDNil(result);
}

@end

