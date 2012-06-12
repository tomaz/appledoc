//
//  NSString+ParseKitAdditions.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 11/5/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "NSString+ParseKitAdditions.h"

@implementation NSString (ParseKitAdditions)

- (NSString *)stringByTrimmingQuotes {
    NSUInteger len = [self length];
    
    if (len < 2) {
        return self;
    }
    
    NSRange r = NSMakeRange(0, len);
    
    unichar c = [self characterAtIndex:0];
    if (!isalnum(c)) {
        unichar quoteChar = c;
        r.location = 1;
        r.length -= 1;

        c = [self characterAtIndex:len - 1];
        if (c == quoteChar) {
            r.length -= 1;
        }
        return [self substringWithRange:r];
    } else {
        return self;
    }
}

@end
