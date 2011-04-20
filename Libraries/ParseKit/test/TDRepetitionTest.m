//
//  PKRepetitionTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/13/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDRepetitionTest.h"

@interface PKParser ()
- (NSSet *)allMatchesFor:(NSSet *)inAssemblies;
@end

@implementation TDRepetitionTest

- (void)setUp {
}


- (void)tearDown {
    [a release];
    [p release];
}


#pragma mark -

- (void)testWordRepetitionAllMatchesForFooSpaceBarSpaceBaz {
    s = @"foo bar baz";
    a = [[PKTokenAssembly alloc] initWithString:s];
    
    p = [[PKRepetition alloc] initWithSubparser:[PKWord word]];
    
    NSSet *all = [p allMatchesFor:[NSSet setWithObject:a]];
    NSLog(@"all: %@", all);
    
    TDNotNil(all);
    NSUInteger c = [all count];
    TDEquals((NSUInteger)4, c);
}


- (void)testWordRepetitionBestMatchForFooSpaceBarSpaceBaz {
    s = @"foo bar baz";
    a = [[PKTokenAssembly alloc] initWithString:s];
    
    p = [[PKRepetition alloc] initWithSubparser:[PKWord word]];
    
    
    PKAssembly *result = [p bestMatchFor:a];
    TDNotNil(result);
    TDEqualObjects(@"[foo, bar, baz]foo/bar/baz^", [result description]);
}


- (void)testWordRepetitionBestMatchForFooSpaceBarSpace123 {
    s = @"foo bar 123";
    a = [[PKTokenAssembly alloc] initWithString:s];
    
    p = [[PKRepetition alloc] initWithSubparser:[PKWord word]];

    PKAssembly *result = [p bestMatchFor:a];
    TDNotNil(result);
    TDEqualObjects(@"[foo, bar]foo/bar^123", [result description]);
}


- (void)testWordRepetitionAllMatchesForFooSpaceBarSpace123 {
    s = @"foo bar 123";
    a = [[PKTokenAssembly alloc] initWithString:s];
    
    p = [[PKRepetition alloc] initWithSubparser:[PKWord word]];
    
    NSSet *all = [p allMatchesFor:[NSSet setWithObject:a]];
    NSLog(@"all: %@", all);
    
    TDNotNil(all);
    NSUInteger c = [all count];
    TDEquals((NSUInteger)3, c);
}    


- (void)testWordRepetitionAllMatchesFooSpace123SpaceBaz {
    s = @"foo 123 baz";
    a = [[PKTokenAssembly alloc] initWithString:s];
    
    p = [[PKRepetition alloc] initWithSubparser:[PKWord word]];
    
    NSSet *all = [p allMatchesFor:[NSSet setWithObject:a]];
    NSLog(@"all: %@", all);
    
    TDNotNil(all);
    NSUInteger c = [all count];
    TDEquals((NSUInteger)2, c);
}    


- (void)testNumRepetitionAllMatchesForFooSpaceBarSpaceBaz {
    s = @"foo bar baz";
    a = [[PKTokenAssembly alloc] initWithString:s];
    
    p = [[PKRepetition alloc] initWithSubparser:[PKNumber number]];
    
    NSSet *all = [p allMatchesFor:[NSSet setWithObject:a]];
    NSLog(@"all: %@", all);
    
    TDNotNil(all);
    NSUInteger c = [all count];
    TDEquals((NSUInteger)1, c);
}    


- (void)testWordRepetitionCompleteMatchForFooSpaceBarSpaceBaz {
    s = @"foo bar baz";
    a = [[PKTokenAssembly alloc] initWithString:s];
    
    p = [[PKRepetition alloc] initWithSubparser:[PKWord word]];
    
    PKAssembly *result = [p completeMatchFor:a];
    TDNotNil(result);
    TDEqualObjects(@"[foo, bar, baz]foo/bar/baz^", [result description]);
}    


- (void)testWordRepetitionCompleteMatchForFooSpaceBarSpace123 {
    s = @"foo bar 123";
    a = [[PKTokenAssembly alloc] initWithString:s];
    
    p = [[PKRepetition alloc] initWithSubparser:[PKWord word]];
    
    PKAssembly *result = [p completeMatchFor:a];
    TDNil(result);
}    


- (void)testWordRepetitionCompleteMatchFor456SpaceBarSpace123 {
    s = @"456 bar 123";
    a = [[PKTokenAssembly alloc] initWithString:s];
    
    p = [[PKRepetition alloc] initWithSubparser:[PKWord word]];
    
    PKAssembly *result = [p completeMatchFor:a];
    TDNil(result);
}    


- (void)testNumRepetitionCompleteMatchFor456SpaceBarSpace123 {
    s = @"456 bar 123";
    a = [[PKTokenAssembly alloc] initWithString:s];
    
    p = [[PKRepetition alloc] initWithSubparser:[PKNumber number]];
    
    PKAssembly *result = [p completeMatchFor:a];
    TDNil(result);
}    


- (void)testNumRepetitionAllMatchesFor123Space456SpaceBaz {
    s = @"123 456 baz";
    a = [[PKTokenAssembly alloc] initWithString:s];
    
    p = [[PKRepetition alloc] initWithSubparser:[PKNumber number]];
    
    NSSet *all = [p allMatchesFor:[NSSet setWithObject:a]];
    
    TDNotNil(all);
    NSInteger c = [all count];
    TDEquals((NSUInteger)3, (NSUInteger)c);
}    


- (void)testNumRepetitionBestMatchFor123Space456SpaceBaz {
    s = @"123 456 baz";
    a = [[PKTokenAssembly alloc] initWithString:s];
    
    p = [[PKRepetition alloc] initWithSubparser:[PKNumber number]];
    
    PKAssembly *result = [p bestMatchFor:a];
    
    TDNotNil(result);
    TDEqualObjects(@"[123, 456]123/456^baz", [result description]);
}    


- (void)testNumRepetitionCompleteMatchFor123 {
    s = @"123";
    a = [[PKTokenAssembly alloc] initWithString:s];
    
    p = [[PKRepetition alloc] initWithSubparser:[PKNumber number]];
    
    PKAssembly *result = [p completeMatchFor:a];
    
    TDNotNil(result);
    TDEqualObjects(@"[123]123^", [result description]);
}    


- (void)testWordRepetitionCompleteMatchFor123 {
    s = @"123";
    a = [[PKTokenAssembly alloc] initWithString:s];
    
    p = [[PKRepetition alloc] initWithSubparser:[PKWord word]];
    
    PKAssembly *result = [p completeMatchFor:a];
    
    TDNil(result);
}    


- (void)testWordRepetitionBestMatchForFoo {
    s = @"foo";
    a = [[PKTokenAssembly alloc] initWithString:s];
    
    p = [[PKRepetition alloc] initWithSubparser:[PKWord word]];
    
    PKAssembly *result = [p bestMatchFor:a];
    TDNotNil(result);
    TDEqualObjects(@"[foo]foo^", [result description]);
}

@end
