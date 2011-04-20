//
//  PKPattern.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 5/31/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/PKPattern.h>
#import "RegexKitLite.h"

@implementation PKPattern

+ (id)patternWithString:(NSString *)s {
    return [self patternWithString:s options:PKPatternOptionsNone];
}


+ (id)patternWithString:(NSString *)s options:(PKPatternOptions)opts {
    return [[[self alloc] initWithString:s options:opts] autorelease];
}


- (id)initWithString:(NSString *)s {
    return [self initWithString:s options:PKPatternOptionsNone];
}

    
- (id)initWithString:(NSString *)s options:(PKPatternOptions)opts {
    if (self = [super initWithString:s]) {
        options = opts;
    }
    return self;
}


- (BOOL)qualifies:(id)obj {
    PKToken *tok = (PKToken *)obj;

    NSRange r = NSMakeRange(0, [tok.stringValue length]);

    return NSEqualRanges(r, [tok.stringValue rangeOfRegex:self.string options:(uint32_t)options inRange:r capture:0 error:nil]);
}

@end
