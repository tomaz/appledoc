//
//  PKSequenceTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/13/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDSequenceTest.h"

@interface PKParser ()
- (NSSet *)allMatchesFor:(NSSet *)inAssemblies;
@end

@implementation TDSequenceTest

- (void)tearDown {
}

- (void)testDiscard {
    s = @"foo -";
    a = [PKTokenAssembly assemblyWithString:s];
    
    p = [PKSequence sequence];
    [p add:[PKLiteral literalWithString:@"foo"]];
    [p add:[[PKSymbol symbolWithString:@"-"] discard]];
    
    PKAssembly *result = [p bestMatchFor:a];
    
    TDNotNil(result);
    TDEqualObjects(@"[foo]foo/-^", [result description]);
}


- (void)testDiscard2 {
    s = @"foo foo -";
    a = [PKTokenAssembly assemblyWithString:s];
    
    p = [PKSequence sequence];
    [p add:[PKLiteral literalWithString:@"foo"]];
    [p add:[PKLiteral literalWithString:@"foo"]];
    [p add:[[PKSymbol symbolWithString:@"-"] discard]];
    
    PKAssembly *result = [p bestMatchFor:a];
    
    TDNotNil(result);
    TDEqualObjects(@"[foo, foo]foo/foo/-^", [result description]);
}


- (void)testDiscard3 {
    s = @"foo - foo";
    a = [PKTokenAssembly assemblyWithString:s];
    
    p = [PKSequence sequence];
    [p add:[PKLiteral literalWithString:@"foo"]];
    [p add:[[PKSymbol symbolWithString:@"-"] discard]];
    [p add:[PKLiteral literalWithString:@"foo"]];
    
    PKAssembly *result = [p bestMatchFor:a];
    
    TDNotNil(result);
    TDEqualObjects(@"[foo, foo]foo/-/foo^", [result description]);
}


- (void)testDiscard1 {
    s = @"- foo";
    a = [PKTokenAssembly assemblyWithString:s];
    
    p = [PKSequence sequence];
    [p add:[[PKSymbol symbolWithString:@"-"] discard]];
    [p add:[PKLiteral literalWithString:@"foo"]];
    
    PKAssembly *result = [p bestMatchFor:a];
    
    TDNotNil(result);
    TDEqualObjects(@"[foo]-/foo^", [result description]);
}


- (void)testDiscard4 {
    s = @"- foo -";
    a = [PKTokenAssembly assemblyWithString:s];
    
    p = [PKSequence sequence];
    [p add:[[PKSymbol symbolWithString:@"-"] discard]];
    [p add:[PKLiteral literalWithString:@"foo"]];
    [p add:[[PKSymbol symbolWithString:@"-"] discard]];
    
    PKAssembly *result = [p bestMatchFor:a];
    
    TDNotNil(result);
    TDEqualObjects(@"[foo]-/foo/-^", [result description]);
}


- (void)testDiscard5 {
    s = @"- foo + foo";
    a = [PKTokenAssembly assemblyWithString:s];
    
    p = [PKSequence sequence];
    [p add:[[PKSymbol symbolWithString:@"-"] discard]];
    [p add:[PKLiteral literalWithString:@"foo"]];
    [p add:[[PKSymbol symbolWithString:@"+"] discard]];
    [p add:[PKLiteral literalWithString:@"foo"]];
    
    PKAssembly *result = [p bestMatchFor:a];
    
    TDNotNil(result);
    TDEqualObjects(@"[foo, foo]-/foo/+/foo^", [result description]);
}


- (void)testTrueLiteralBestMatchForFooSpaceBarSpaceBaz {
    s = @"foo bar baz";
    a = [PKTokenAssembly assemblyWithString:s];
    
    p = [PKSequence sequence];
    [p add:[PKLiteral literalWithString:@"foo"]];
    [p add:[PKLiteral literalWithString:@"bar"]];
    [p add:[PKLiteral literalWithString:@"baz"]];
    
    PKAssembly *result = [p bestMatchFor:a];
    
    TDNotNil(result);
    TDEqualObjects(@"[foo, bar, baz]foo/bar/baz^", [result description]);
}


- (void)testTrueLiteralBestMatchForFooSpaceBarSpaceBaz1 {
    s = @"foo bar baz";
    a = [PKTokenAssembly assemblyWithString:s];

    PKParser *foo = [PKLiteral literalWithString:@"foo"];
    PKParser *bar = [PKLiteral literalWithString:@"bar"];
    PKParser *baz = [PKLiteral literalWithString:@"baz"];
    p = [PKSequence sequenceWithSubparsers:foo, baz, bar, nil];
    
    PKAssembly *result = [p bestMatchFor:a];
    
    TDNil(result);
}


- (void)testFalseLiteralBestMatchForFooSpaceBarSpaceBaz {
    s = @"foo bar baz";
    a = [PKTokenAssembly assemblyWithString:s];
    
    p = [PKSequence sequence];
    [p add:[PKLiteral literalWithString:@"foo"]];
    [p add:[PKLiteral literalWithString:@"foo"]];
    [p add:[PKLiteral literalWithString:@"baz"]];
    
    PKAssembly *result = [p bestMatchFor:a];
    TDNil(result);
}


- (void)testTrueLiteralCompleteMatchForFooSpaceBarSpaceBaz {
    s = @"foo bar baz";
    a = [PKTokenAssembly assemblyWithString:s];
    
    p = [PKSequence sequence];
    [p add:[PKLiteral literalWithString:@"foo"]];
    [p add:[PKLiteral literalWithString:@"bar"]];
    [p add:[PKLiteral literalWithString:@"baz"]];
    
    PKAssembly *result = [p completeMatchFor:a];
    
    TDNotNil(result);
    TDEqualObjects(@"[foo, bar, baz]foo/bar/baz^", [result description]);
}


- (void)testTrueLiteralCompleteMatchForFooSpaceBarSpaceBaz1 {
    s = @"foo bar baz";
    a = [PKTokenAssembly assemblyWithString:s];
    
    p = [PKSequence sequence];
    [p add:[PKLiteral literalWithString:@"foo"]];
    [p add:[PKWord word]];
    [p add:[PKLiteral literalWithString:@"baz"]];
    
    PKAssembly *result = [p completeMatchFor:a];
    
    TDNotNil(result);
    TDEqualObjects(@"[foo, bar, baz]foo/bar/baz^", [result description]);
}


- (void)testFalseLiteralCompleteMatchForFooSpaceBarSpaceBaz {
    s = @"foo bar baz";
    a = [PKTokenAssembly assemblyWithString:s];
    
    p = [PKSequence sequence];
    [p add:[PKLiteral literalWithString:@"foo"]];
    [p add:[PKLiteral literalWithString:@"foo"]];
    [p add:[PKLiteral literalWithString:@"baz"]];
    
    PKAssembly *result = [p completeMatchFor:a];
    TDNil(result);
}


- (void)testFalseLiteralCompleteMatchForFooSpaceBarSpaceBaz1 {
    s = @"foo bar baz";
    a = [PKTokenAssembly assemblyWithString:s];
    
    p = [PKSequence sequence];
    [p add:[PKLiteral literalWithString:@"foo"]];
    [p add:[PKNumber number]];
    [p add:[PKLiteral literalWithString:@"baz"]];
    
    PKAssembly *result = [p completeMatchFor:a];
    TDNil(result);
}


- (void)testTrueLiteralAllMatchsForFooSpaceBarSpaceBaz {
    s = @"foo bar baz";
    a = [PKTokenAssembly assemblyWithString:s];
    
    p = [PKSequence sequence];
    [p add:[PKLiteral literalWithString:@"foo"]];
    [p add:[PKLiteral literalWithString:@"bar"]];
    [p add:[PKLiteral literalWithString:@"baz"]];
    
    PKAssembly *result = [p bestMatchFor:a];
    
    TDNotNil(result);
}


- (void)testFalseLiteralAllMatchsForFooSpaceBarSpaceBaz {
    s = @"foo bar baz";
    a = [PKTokenAssembly assemblyWithString:s];
    
    p = [PKSequence sequence];
    [p add:[PKLiteral literalWithString:@"foo"]];
    [p add:[PKLiteral literalWithString:@"123"]];
    [p add:[PKLiteral literalWithString:@"baz"]];
    
    NSSet *result = [p allMatchesFor:[NSSet setWithObject:a]];
    
    TDNotNil(result);
    NSUInteger c = [result count];
    TDEquals((NSUInteger)0, c);
}

@end
