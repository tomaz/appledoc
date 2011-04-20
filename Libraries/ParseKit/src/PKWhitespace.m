//
//  PKWhitespace.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 6/19/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "PKWhitespace.h"
#import <ParseKit/PKToken.h>

@implementation PKWhitespace

+ (id)whitespace {
    return [[[self alloc] initWithString:nil] autorelease];
}


- (BOOL)qualifies:(id)obj {
    PKToken *tok = (PKToken *)obj;
    return tok.isWhitespace;
}

@end