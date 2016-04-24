//
//  PKURLState.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 3/26/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/PKURLState.h>
#import <ParseKit/PKReader.h>
#import <ParseKit/PKTokenizer.h>
#import <ParseKit/PKToken.h>
#import <ParseKit/PKTypes.h>

// Gruber original
//  \b(([\w-]+://?|www[.])[^\s()<>]+(?:\([\w\d]+\)|([^[:punct:]\s]|/)))

@interface PKToken ()
@property (nonatomic, readwrite) NSUInteger offset;
@end

@interface PKTokenizerState ()
- (void)resetWithReader:(PKReader *)r;
- (void)append:(PKUniChar)c;
- (NSString *)bufferedString;
- (PKTokenizerState *)nextTokenizerStateFor:(PKUniChar)c tokenizer:(PKTokenizer *)t;
@end

@interface PKURLState ()
- (BOOL)parseWWWFromReader:(PKReader *)r;
- (BOOL)parseSchemeFromReader:(PKReader *)r;
- (BOOL)parseHostFromReader:(PKReader *)r;
- (void)parsePathFromReader:(PKReader *)r;
@end

@implementation PKURLState

- (id)init {
    if (self = [super init]) {
        self.allowsWWWPrefix = YES;
    }
    return self;
}


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
    BOOL matched = NO;
    if (allowsWWWPrefix && 'w' == c) {
        matched = [self parseWWWFromReader:r];

        if (!matched) {
            [r unread:[[self bufferedString] length]];
            [self resetWithReader:r];
            c = cin;
        }
    }
    
    if (!matched) {
        matched = [self parseSchemeFromReader:r];
    }
    if (matched) {
        matched = [self parseHostFromReader:r];
    }
    if (matched) {
        [self parsePathFromReader:r];
    }
    
    NSString *s = [self bufferedString];

    if (PKEOF != c) {
        [r unread];
    } 
    
    if (matched) {
        if ('.' == lastChar || ',' == lastChar || '-' == lastChar) {
            s = [s substringToIndex:[s length] - 1];
            [r unread];
        }
        
        PKToken *tok = [PKToken tokenWithTokenType:PKTokenTypeURL stringValue:s floatValue:0.0];
        tok.offset = offset;
        return tok;
    } else {
        [r unread:[s length] - 1];
        return [[self nextTokenizerStateFor:cin tokenizer:t] nextTokenFromReader:r startingWith:cin tokenizer:t];
    }
}


- (BOOL)parseWWWFromReader:(PKReader *)r {
    BOOL result = NO;
    NSInteger wcount = 0;
    
    while ('w' == c) {
        wcount++;
        [self append:c];
        c = [r read];

        if (3 == wcount) {
            if ('.' == c) {
                [self append:c];
                c = [r read];
                result = YES;
                break;
            } else {
                result = NO;
                break;
            }
        }
    }
    
    return result;
}


- (BOOL)parseSchemeFromReader:(PKReader *)r {
    BOOL result = NO;

    // [[:alpha:]-]+://?
    for (;;) {
        if (isalnum(c) || '-' == c) {
            [self append:c];
        } else if (':' == c) {
            [self append:c];
            
            c = [r read];
            if ('/' == c) { // endgame
                [self append:c];
                c = [r read];
                if ('/' == c) {
                    [self append:c];
                    c = [r read];
                }
                result = YES;
                break;
            } else {
                result = NO;
                break;
            }
        } else {
            result = NO;
            break;
        }

        c = [r read];
    }
    
    return result;
}


- (BOOL)parseHostFromReader:(PKReader *)r {
    BOOL result = NO;
    BOOL hasAtLeastOneChar = NO;
//    BOOL hasDot = NO;
    
    // ^[:space:]()<>
    for (;;) {
        if (PKEOF == c || isspace(c) || '(' == c || ')' == c || '<' == c || '>' == c) {
            result = hasAtLeastOneChar;
            break;
        } else if ('/' == c && hasAtLeastOneChar/* && hasDot*/) {
            result = YES;
            break;
        } else {
//            if ('.' == c) {
//                hasDot = YES;
//            }
            hasAtLeastOneChar = YES;
            [self append:c];
            c = [r read];
        }
    }
    
    return result;
}


- (void)parsePathFromReader:(PKReader *)r {
    BOOL hasOpenParen = NO;
    
    for (;;) {
        if (PKEOF == c || isspace(c) || '<' == c || '>' == c) {
            break;
        } else if (')' == c) {
            if (hasOpenParen) {
                hasOpenParen = NO;
                [self append:c];
            } else {
                break;
            }
        } else {
            if (!hasOpenParen) {
                hasOpenParen = ('(' == c);
            }
            [self append:c];
        }
        c = [r read];
    }
}

@synthesize allowsWWWPrefix;
@end
