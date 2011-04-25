//
//  PKReader.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/21/06.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/PKReader.h>

@implementation PKReader

- (id)init {
    return [self initWithString:nil];
}


- (id)initWithString:(NSString *)s {
    if (self = [super init]) {
        self.string = s;
    }
    return self;
}


- (void)dealloc {
    self.string = nil;
    [super dealloc];
}


- (NSString *)string {
    return [[string retain] autorelease];
}


- (void)setString:(NSString *)s {
    if (string != s) {
        [string autorelease];
        string = [s copy];
        length = [string length];
    }
    // reset cursor
    offset = 0;
}


- (PKUniChar)read {
    if (0 == length || offset > length - 1) {
        return PKEOF;
    }
    return [string characterAtIndex:offset++];
}


- (void)unread {
    offset = (0 == offset) ? 0 : offset - 1;
}


- (void)unread:(NSUInteger)count {
    NSUInteger i = 0;
    for ( ; i < count; i++) {
        [self unread];
    }
}

@synthesize offset;
@end
