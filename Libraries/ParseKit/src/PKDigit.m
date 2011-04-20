//
//  PKDigit.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/14/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/PKDigit.h>
#import <ParseKit/PKTypes.h>

@implementation PKDigit

+ (id)digit {
    return [[[self alloc] initWithString:nil] autorelease];
}


- (BOOL)qualifies:(id)obj {
    PKUniChar c = [obj intValue];
    return isdigit(c);
}

@end
