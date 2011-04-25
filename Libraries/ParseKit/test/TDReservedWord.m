//
//  PKReservedWord.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/13/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/TDReservedWord.h>
#import <ParseKit/PKToken.h>

static NSArray *sTDReservedWords = nil;

@interface TDReservedWord ()
+ (NSArray *)reservedWords;
@end

@implementation TDReservedWord

+ (NSArray *)reservedWords {
    return [[sTDReservedWords retain] autorelease];
}


+ (void)setReservedWords:(NSArray *)inWords {
    if (inWords != sTDReservedWords) {
        [sTDReservedWords autorelease];
        sTDReservedWords = [inWords copy];
    }
}


- (BOOL)qualifies:(id)obj {
    PKToken *tok = (PKToken *)obj;
    if (!tok.isWord) {
        return NO;
    }
    
    NSString *s = tok.stringValue;
    return [s length] && [[TDReservedWord reservedWords] containsObject:s];
}

@end
