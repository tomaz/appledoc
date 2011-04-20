//
//  PKTokenArraySourceTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 12/12/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDTokenArraySourceTest.h"

@implementation TDTokenArraySourceTest

- (void)setUp {
}


- (void)testFoo {
    d = @";";
    s = @"I came; I saw; I left in peace.;";
    t = [[[PKTokenizer alloc] initWithString:s] autorelease];
    tas = [[[PKTokenArraySource alloc] initWithTokenizer:t delimiter:d] autorelease];
    
    TDTrue([tas hasMore]);
    NSArray *a = [tas nextTokenArray];
    TDNotNil(a);
    TDEquals((NSUInteger)2, [a count]);
    TDEqualObjects(@"I", [[a objectAtIndex:0] stringValue]);
    TDEqualObjects(@"came", [[a objectAtIndex:1] stringValue]);

    TDTrue([tas hasMore]);
    a = [tas nextTokenArray];
    TDNotNil(a);
    TDEquals((NSUInteger)2, [a count]);
    TDEqualObjects(@"I", [[a objectAtIndex:0] stringValue]);
    TDEqualObjects(@"saw", [[a objectAtIndex:1] stringValue]);

    TDTrue([tas hasMore]);
    a = [tas nextTokenArray];
    TDNotNil(a);
    TDEquals((NSUInteger)5, [a count]);
    TDEqualObjects(@"I", [[a objectAtIndex:0] stringValue]);
    TDEqualObjects(@"left", [[a objectAtIndex:1] stringValue]);
    TDEqualObjects(@"in", [[a objectAtIndex:2] stringValue]);
    TDEqualObjects(@"peace", [[a objectAtIndex:3] stringValue]);
    TDEqualObjects(@".", [[a objectAtIndex:4] stringValue]);

    TDFalse([tas hasMore]);
    a = [tas nextTokenArray];
    TDNil(a);
}
@end
