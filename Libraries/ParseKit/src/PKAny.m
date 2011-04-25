//
//  PKAny.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 12/14/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/PKAny.h>
#import <ParseKit/PKToken.h>

@implementation PKAny

+ (id)any {
    return [[[self alloc] initWithString:nil] autorelease];
}


- (BOOL)qualifies:(id)obj {
    return [obj isMemberOfClass:[PKToken class]];
}

@end
