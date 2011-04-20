//
//  PKReaderTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/21/06.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDReaderTest.h"


@implementation TDReaderTest

- (void)setUp {
    string = @"abcdefghijklmnopqrstuvwxyz";
    [string retain];
    reader = [[PKReader alloc] initWithString:string];
}


- (void)tearDown {
    [string release];
    [reader release];
}


#pragma mark -

- (void)testReadCharsMatch {
    TDNotNil(reader);
    NSInteger len = [string length];
    PKUniChar c;
    NSInteger i = 0;
    for ( ; i < len; i++) {
        c = [string characterAtIndex:i];
        TDEquals(c, [reader read]);
    }
}


- (void)testReadTooFar {
    NSInteger len = [string length];
    NSInteger i = 0;
    for ( ; i < len; i++) {
        [reader read];
    }
    TDEquals(PKEOF, [reader read]);
}


- (void)testUnread {
    [reader read];
    [reader unread];
    PKUniChar a = 'a';
    TDEquals(a, [reader read]);

    [reader read];
    [reader read];
    [reader unread];
    PKUniChar c = 'c';
    TDEquals(c, [reader read]);
}


- (void)testUnreadTooFar {
    [reader unread];
    PKUniChar a = 'a';
    TDEquals(a, [reader read]);

    [reader unread];
    [reader unread];
    [reader unread];
    [reader unread];
    PKUniChar a2 = 'a';
    TDEquals(a2, [reader read]);
}

@end
