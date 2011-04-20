//
//  PKChar.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/14/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/PKChar.h>

@implementation PKChar

+ (id)char {
    return [[[self alloc] initWithString:nil] autorelease];
}


- (BOOL)qualifies:(id)obj {
    return YES;
}

@end
