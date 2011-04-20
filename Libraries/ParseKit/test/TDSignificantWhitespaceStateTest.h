//
//  PKSignificantWhitespaceStateTest.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/14/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <ParseKit/ParseKit.h>

@interface TDSignificantWhitespaceStateTest : SenTestCase {
    TDSignificantWhitespaceState *whitespaceState;
    PKReader *r;
    NSString *s;    
}

@end
