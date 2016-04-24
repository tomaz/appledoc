//  Copyright 2010 Todd Ditchendorf
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

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
- (PKTokenizerState *)nextTokenizerStateFor:(PKUniChar)c tokenizer:(PKTokenizer *)t;
- (void)append:(PKUniChar)c;
- (NSString *)bufferedString;
@end

@interface PKNumberState ()
- (CGFloat)absorbDigitsFromReader:(PKReader *)r;
- (CGFloat)value;
- (void)parseLeftSideFromReader:(PKReader *)r;
- (void)parseRightSideFromReader:(PKReader *)r;
- (void)parseExponentFromReader:(PKReader *)r;
- (void)reset:(PKUniChar)cin;
- (void)checkForHex:(PKReader *)r;
- (void)checkForOctal;
@end

@implementation PKNumberState

- (PKToken *)nextTokenFromReader:(PKReader *)r startingWith:(PKUniChar)cin tokenizer:(PKTokenizer *)t {
    NSParameterAssert(r);
    NSParameterAssert(t);

    [self resetWithReader:r];
    isNegative = NO;
    originalCin = cin;
    
    if ('-' == cin) {
        isNegative = YES;
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
        if (isDecimal) {
            [self parseRightSideFromReader:r];
        }
    }
    
    // erroneous ., +, -, or 0x
    if (!gotADigit) {
        if (isHex) {
            [r unread];
            return [PKToken tokenWithTokenType:PKTokenTypeNumber stringValue:@"0" floatValue:0.0];
        } else {
            if (isNegative && PKEOF != c) { // ??
                [r unread];
            }
            return [t.symbolState nextTokenFromReader:r startingWith:originalCin tokenizer:t];
        }
    }
    
    if (PKEOF != c) {
        [r unread];
    }

    if (isNegative) {
        floatValue = -floatValue;
    }
    
    PKToken *tok = [PKToken tokenWithTokenType:PKTokenTypeNumber stringValue:[self bufferedString] floatValue:[self value]];
    tok.offset = offset;
    return tok;
}


- (CGFloat)value {
    CGFloat result = (CGFloat)floatValue;
    
    NSUInteger i = 0;
    for ( ; i < exp; i++) {
        if (isNegativeExp) {
            result /= (CGFloat)10.0;
        } else {
            result *= (CGFloat)10.0;
        }
    }
    
    return (CGFloat)result;
}


- (CGFloat)absorbDigitsFromReader:(PKReader *)r {
    CGFloat divideBy = 1.0;
    CGFloat v = 0.0;
    BOOL isHexAlpha = NO;
    
    while (1) {
        isHexAlpha = NO;
        if (allowsHexadecimalNotation) {
            [self checkForHex:r];
            if (c >= 'a' && c <= 'f' || c >= 'A' && c <= 'F') {
                isHexAlpha = YES;
            }
        }
        
        if (isdigit(c) || isHexAlpha) {
            [self append:c];
            len++;
            gotADigit = YES;

            if (allowsOctalNotation) {
                [self checkForOctal];
            }
            
            if (isHexAlpha) {
                if (c >= 'a' && c <= 'f') {
                    c = toupper(c);
                }
                c -= 7;
            }
            v = v * base + (c - '0');
            c = [r read];
            if (isFraction) {
                divideBy *= base;
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
    isFraction = NO;
    floatValue = [self absorbDigitsFromReader:r];
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
                isFraction = YES;
                floatValue += [self absorbDigitsFromReader:r];
            }
        }
    }
    
    if (allowsScientificNotation) {
        [self parseExponentFromReader:r];
    }
}


- (void)parseExponentFromReader:(PKReader *)r {
    NSParameterAssert(r);    
    if ('e' == c || 'E' == c) {
        PKUniChar e = c;
        c = [r read];
        
        BOOL hasExp = isdigit(c);
        isNegativeExp = ('-' == c);
        BOOL positiveExp = ('+' == c);
        
        if (!hasExp && (isNegativeExp || positiveExp)) {
            c = [r read];
            hasExp = isdigit(c);
        }
        if (PKEOF != c) {
            [r unread];
        }
        if (hasExp) {
            [self append:e];
            if (isNegativeExp) {
                [self append:'-'];
            } else if (positiveExp) {
                [self append:'+'];
            }
            c = [r read];
            isFraction = NO;
            exp = [self absorbDigitsFromReader:r];
        }
    }
}


- (void)reset:(PKUniChar)cin {
    c = cin;
    firstNum = cin;
    gotADigit = NO;
    isFraction = NO;
    isDecimal = YES;
    isHex = NO;
    len = 0;
    base = (CGFloat)10.0;
    floatValue = (CGFloat)0.0;
    exp = (CGFloat)0.0;
    isNegativeExp = NO;
}


- (void)checkForHex:(PKReader *)r {
    if ('x' == c && '0' == firstNum && !isFraction && 1 == len) {
        [self append:c];
        len++;
        c = [r read];
        isDecimal = NO;
        base = (CGFloat)16.0;
        isHex = YES;
        gotADigit = NO;
    }
}


- (void)checkForOctal {
    if ('0' == firstNum && !isFraction && isDecimal && 2 == len) {
        isDecimal = NO;
        base = (CGFloat)8.0;
    }
}

@synthesize allowsTrailingDot;
@synthesize allowsScientificNotation;
@synthesize allowsOctalNotation;
@synthesize allowsHexadecimalNotation;
@end
