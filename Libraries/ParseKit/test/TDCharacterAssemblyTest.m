//
//  PKCharacterAssemblyTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/15/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDCharacterAssemblyTest.h"

@interface PKAssembly ()
- (id)next;
- (BOOL)hasMore;
@property (nonatomic, readonly) NSUInteger objectsConsumed;
@property (nonatomic, readonly) NSUInteger objectsRemaining;
@end

@implementation TDCharacterAssemblyTest

- (void)testAbc {
    s = @"abc";
    a = [PKCharacterAssembly assemblyWithString:s];

    TDNotNil(a);
    TDEquals((NSUInteger)3, [s length]);
    TDEquals((NSUInteger)0, a.objectsConsumed);
    TDEquals((NSUInteger)3, a.objectsRemaining);
    TDEquals(YES, [a hasMore]);
    
    id obj = [a next];
    TDEqualObjects(obj, [NSNumber numberWithInteger:'a']);
    TDEquals((NSUInteger)3, [s length]);
    TDEquals((NSUInteger)1, a.objectsConsumed);
    TDEquals((NSUInteger)2, a.objectsRemaining);
    TDEquals(YES, [a hasMore]);

    obj = [a next];
    TDEqualObjects(obj, [NSNumber numberWithInteger:'b']);
    TDEquals((NSUInteger)3, [s length]);
    TDEquals((NSUInteger)2, a.objectsConsumed);
    TDEquals((NSUInteger)1, a.objectsRemaining);
    TDEquals(YES, [a hasMore]);

    obj = [a next];
    TDEqualObjects(obj, [NSNumber numberWithInteger:'c']);
    TDEquals((NSUInteger)3, [s length]);
    TDEquals((NSUInteger)3, a.objectsConsumed);
    TDEquals((NSUInteger)0, a.objectsRemaining);
    TDEquals(NO, [a hasMore]);

    obj = [a next];
    TDNil(obj);
    TDEquals((NSUInteger)3, [s length]);
    TDEquals((NSUInteger)3, a.objectsConsumed);
    TDEquals((NSUInteger)0, a.objectsRemaining);
    TDEquals(NO, [a hasMore]);
}

@end
