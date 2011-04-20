//
//  PKCaseInsensitiveLiteral.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/13/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/PKCaseInsensitiveLiteral.h>
#import <ParseKit/PKToken.h>

@implementation PKCaseInsensitiveLiteral

- (BOOL)qualifies:(id)obj {
    return NSOrderedSame == [literal.stringValue caseInsensitiveCompare:[obj stringValue]];
//    return [literal isEqualIgnoringCase:obj];
}

@end
