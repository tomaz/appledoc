//
//  PKWhitespaceState.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/20/06.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/PKWhitespaceState.h>
#import <ParseKit/PKReader.h>
#import <ParseKit/PKTokenizer.h>
#import <ParseKit/PKToken.h>
#import <ParseKit/PKTypes.h>

#define PKTRUE (id)kCFBooleanTrue
#define PKFALSE (id)kCFBooleanFalse

@interface PKToken ()
@property (nonatomic, readwrite) NSUInteger offset;
@end

@interface PKTokenizerState ()
- (void)resetWithReader:(PKReader *)r;
- (void)append:(PKUniChar)c;
- (NSString *)bufferedString;
@end

@interface PKWhitespaceState ()
@property (nonatomic, retain) NSMutableArray *whitespaceChars;
@end

@implementation PKWhitespaceState

- (id)init {
    if (self = [super init]) {
        const NSUInteger len = 255;
        self.whitespaceChars = [NSMutableArray arrayWithCapacity:len];
        NSUInteger i = 0;
        for ( ; i <= len; i++) {
            [whitespaceChars addObject:PKFALSE];
        }
        
        [self setWhitespaceChars:YES from:0 to:' '];
    }
    return self;
}


- (void)dealloc {
    self.whitespaceChars = nil;
    [super dealloc];
}


- (void)setWhitespaceChars:(BOOL)yn from:(PKUniChar)start to:(PKUniChar)end {
    NSUInteger len = [whitespaceChars count];
    if (start > len || end > len || start < 0 || end < 0) {
        [NSException raise:@"PKWhitespaceStateNotSupportedException" format:@"PKWhitespaceState only supports setting word chars for chars in the latin1 set (under 256)"];
    }

    id obj = yn ? PKTRUE : PKFALSE;
    NSUInteger i = start;
    for ( ; i <= end; i++) {
        [whitespaceChars replaceObjectAtIndex:i withObject:obj];
    }
}


- (BOOL)isWhitespaceChar:(PKUniChar)cin {
    if (cin < 0 || cin > [whitespaceChars count] - 1) {
        return NO;
    }
    return PKTRUE == [whitespaceChars objectAtIndex:cin];
}


- (PKToken *)nextTokenFromReader:(PKReader *)r startingWith:(PKUniChar)cin tokenizer:(PKTokenizer *)t {
    NSParameterAssert(r);
    if (reportsWhitespaceTokens) {
        [self resetWithReader:r];
    }
    
    PKUniChar c = cin;
    while ([self isWhitespaceChar:c]) {
        if (reportsWhitespaceTokens) {
            [self append:c];
        }
        c = [r read];
    }
    if (PKEOF != c) {
        [r unread];
    }
    
    if (reportsWhitespaceTokens) {
        PKToken *tok = [PKToken tokenWithTokenType:PKTokenTypeWhitespace stringValue:[self bufferedString] floatValue:0.0];
        tok.offset = offset;
        return tok;
    } else {
        return [t nextToken];
    }
}

@synthesize whitespaceChars;
@synthesize reportsWhitespaceTokens;
@end

