//
//  PKComment.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 12/31/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/PKComment.h>
#import <ParseKit/PKToken.h>

@implementation PKComment

+ (id)comment {
    return [[[self alloc] initWithString:nil] autorelease];
}


- (BOOL)qualifies:(id)obj {
    PKToken *tok = (PKToken *)obj;
    return tok.isComment;
}

@end