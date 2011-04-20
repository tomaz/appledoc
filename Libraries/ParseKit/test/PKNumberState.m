//
//  PKNumberState.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/20/06.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/PKNumberState.h>
#import <ParseKit/PKReader.h>
#import <ParseKit/PKToken.h>
#import <ParseKit/PKTokenizer.h>
#import <ParseKit/PKSymbolState.h>
#import <ParseKit/PKTypes.h>

@interface PKToken ()
@property (nonatomic, readwrite) NSUInteger offset;
@end

@interface PKTokenizerState ()
- (void)resetWithReader:(PKReader *)r;
- (void)append:(PKUniChar)c;
- (NSString *)bufferedString;
@end

@interface PKNumberState ()
- (CGFloat)absorbDigitsFromReader:(PKReader *)r isFraction:(BOOL)fraction;
- (CGFloat)value;
- (void)parseLeftSideFromReader:(PKReader *)r;
- (void)parseRightSideFromReader:(PKReader *)r;
- (void)reset:(PKUniChar)cin;
@end

@implementation PKNumberState

- (PKToken *)nextTokenFromReader:(PKReader *)r startingWith:(PKUniChar)cin tokenizer:(PKTokenizer *)t {
    NSParameterAssert(r);
    NSParameterAssert(t);

    [self resetWithReader:r];
    negative = NO;
    PKUniChar originalCin = cin;
    
    if ('-' == cin) {
        negative = YES;
        cin = [r read];
        [self append:'-'];
    } else if ('+' == cin) {
        cin = [r read];
        [self append:'+'];
    }
    
    [self reset:cin];
    if ('.' == c) {
        [self parseRightSideFromReader:r];
    } else {
        [self parseLeftSideFromReader:r];
        [self parseRightSideFromReader:r];
    }
    
    // erroneous ., +, or -
    if (!gotADigit) {
        if (negative && PKEOF != c) { // ??
            [r unread];
        }
        return [t.symbolState nextTokenFromReader:r startingWith:originalCin tokenizer:t];
    }
    
    if (PKEOF != c) {
        [r unread];
    }

    if (negative) {
        floatValue = -floatValue;
    }
    
    PKToken *tok = [PKToken tokenWithTokenType:PKTokenTypeNumber stringValue:[self bufferedString] floatValue:[self value]];
    tok.offset = offset;
    return tok;
}


- (CGFloat)value {
    return floatValue;
}


- (CGFloat)absorbDigitsFromReader:(PKReader *)r isFraction:(BOOL)isFraction {
    CGFloat divideBy = 1.0;
    CGFloat v = 0.0;
    
    while (1) {
        if (isdigit(c)) {
            [self append:c];
            gotADigit = YES;
            v = v * 10.0 + (c - '0');
            c = [r read];
            if (isFraction) {
                divideBy *= 10.0;
            }
        } else {
            break;
        }
    }
    
    if (isFraction) {
        v = v / divideBy;
    }

    return (CGFloat)v;
}


- (void)parseLeftSideFromReader:(PKReader *)r {
    floatValue = [self absorbDigitsFromReader:r isFraction:NO];
}


- (void)parseRightSideFromReader:(PKReader *)r {
    if ('.' == c) {
        PKUniChar n = [r read];
        BOOL nextIsDigit = isdigit(n);
        if (PKEOF != n) {
            [r unread];
        }

        if (nextIsDigit || allowsTrailingDot) {
            [self append:'.'];
            if (nextIsDigit) {
                c = [r read];
                floatValue += [self absorbDigitsFromReader:r isFraction:YES];
            }
        }
    }
}


- (void)reset:(PKUniChar)cin {
    gotADigit = NO;
    floatValue = 0.0;
    c = cin;
}

@synthesize allowsTrailingDot;
@end
