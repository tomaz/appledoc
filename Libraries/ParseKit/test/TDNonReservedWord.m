//
//  PKNonReservedWord.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/13/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/TDNonReservedWord.h>
#import <ParseKit/TDReservedWord.h>
#import <ParseKit/PKToken.h>

@interface TDReservedWord ()
+ (NSArray *)reservedWords;
@end

@implementation TDNonReservedWord

- (BOOL)qualifies:(id)obj {
    PKToken *tok = (PKToken *)obj;
    if (!tok.isWord) {
        return NO;
    }
    
    NSString *s = tok.stringValue;
    return [s length] && ![[TDReservedWord reservedWords] containsObject:s];
}

@end
