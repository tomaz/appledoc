//
//  PKJSValueHolder.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/2/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "PKJSValueHolder.h"

@implementation JSValueHolder

- (id)initWithContext:(JSContextRef)c heldValue:(JSValueRef)v {
    if (self = [super init]) {
        self.context = c;
        self.heldValue = v;
    }
    return self;
}


- (void)dealloc {
    [super dealloc];
}


@synthesize context;
@synthesize heldValue;
@end
