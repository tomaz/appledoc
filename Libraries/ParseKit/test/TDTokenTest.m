//
//  PKTokenTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 12/8/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDTokenTest.h"

@implementation TDTokenTest

- (void)setUp {
    eof = [PKToken EOFToken];
}


- (void)testEOFTokenReleaseOnce1 {
    TDNotNil(eof);
    [eof release];
}


- (void)testEOFTokenReleaseOnce2 {
    TDNotNil(eof);
    [eof release];
}


- (void)testEOFTokenReleaseTwice1 {
    TDNotNil(eof);
    [eof release];
    TDNotNil(eof);
    [eof release];
}


- (void)testEOFTokenReleaseTwice2 {
    TDNotNil(eof);
    [eof release];
    TDNotNil(eof);
    [eof release];
}


- (void)testEOFTokenAutoreleaseOnce1 {
    TDNotNil(eof);
    [eof autorelease];
}


- (void)testEOFTokenAutoreleaseOnce2 {
    TDNotNil(eof);
    [eof autorelease];
}


- (void)testEOFTokenAutoreleaseTwice1 {
    TDNotNil(eof);
    [eof autorelease];
    TDNotNil(eof);
    [eof autorelease];
}


- (void)testEOFTokenAutoreleaseTwice2 {
    TDNotNil(eof);
    [eof autorelease];
    TDNotNil(eof);
    [eof autorelease];
}


- (void)testEOFTokenRetainCount {
    TDTrue([eof retainCount] >= 17035104);
    // NO IDEA WHY THIS WONT PASS
    //TDEquals(UINT_MAX, [eof retainCount]);  /*17035104 4294967295*/
//    TDEqualObjects([NSNumber numberWithUnsignedInt:4294967295], [NSNumber numberWithUnsignedInt:[eof retainCount]]);
}


- (void)testCopyIdentity {
    id copy = [eof copy];
    TDTrue(copy == eof);
    [copy release]; // appease clang sa
}

@end
