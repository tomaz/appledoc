//
//  PKEmailState.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 3/31/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/PKEmailState.h>
#import <ParseKit/PKReader.h>
#import <ParseKit/PKTokenizer.h>
#import <ParseKit/PKToken.h>
#import <ParseKit/PKTypes.h>

@interface PKToken ()
@property (nonatomic, readwrite) NSUInteger offset;
@end

@interface PKTokenizerState ()
- (void)resetWithReader:(PKReader *)r;
- (void)append:(PKUniChar)c;
- (NSString *)bufferedString;
- (PKTokenizerState *)nextTokenizerStateFor:(PKUniChar)c tokenizer:(PKTokenizer *)t;
@end

@interface PKEmailState ()
- (BOOL)parseNameFromReader:(PKReader *)r;
- (BOOL)parseHostFromReader:(PKReader *)r;
@end

@implementation PKEmailState

- (void)dealloc {
    [super dealloc];
}


- (void)append:(PKUniChar)ch {
    lastChar = ch;
    [super append:ch];
}


- (PKToken *)nextTokenFromReader:(PKReader *)r startingWith:(PKUniChar)cin tokenizer:(PKTokenizer *)t {
    NSParameterAssert(r);
    [self resetWithReader:r];
    
    lastChar = PKEOF;
    c = cin;
    BOOL matched = [self parseNameFromReader:r];
    if (matched) {
        matched = [self parseHostFromReader:r];
    }

    if (PKEOF != c) {
        [r unread];
    }
    
    NSString *s = [self bufferedString];
    if (matched) {
        if ('.' == lastChar) {
            s = [s substringToIndex:[s length] - 1];
            [r unread];
        }
        
        PKToken *tok = [PKToken tokenWithTokenType:PKTokenTypeEmail stringValue:s floatValue:0.0];
        tok.offset = offset;
        return tok;
    } else {
        [r unread:[s length] - 1];
        return [[self nextTokenizerStateFor:cin tokenizer:t] nextTokenFromReader:r startingWith:cin tokenizer:t];
    }
}


- (BOOL)parseNameFromReader:(PKReader *)r {
    BOOL result = NO;
    BOOL hasAtLeastOneChar = NO;

    for (;;) {
        if (PKEOF == c || isspace(c)) {
            result = NO;
            break;
        } else if ('@' == c && hasAtLeastOneChar) {
            //[self append:c];
            result = YES;
            break;
        } else {
            hasAtLeastOneChar = YES;
            [self append:c];
            c = [r read];
        }
    }
    
    return result;
}


- (BOOL)parseHostFromReader:(PKReader *)r {
    BOOL result = NO;
    BOOL hasAtLeastOneChar = NO;
    BOOL hasDot = NO;
    
    // ^[:space:]()<>/
    for (;;) {
        if (PKEOF == c || isspace(c) || '(' == c || ')' == c || '<' == c || '>' == c || '/' == c) {
            result = hasAtLeastOneChar && hasDot;
            break;
        } else {
            if ('.' == c) {
                hasDot = YES;
            }
            hasAtLeastOneChar = YES;
            [self append:c];
            c = [r read];
        }
    }
    
    return result;
}

@end
