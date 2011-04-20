//
//  PKSignificantWhitespaceState.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/14/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/TDSignificantWhitespaceState.h>
#import <ParseKit/PKReader.h>
#import <ParseKit/PKTokenizer.h>
#import <ParseKit/PKToken.h>
#import <ParseKit/PKTypes.h>

@interface PKTokenizerState ()
- (void)resetWithReader:(PKReader *)r;
- (void)append:(PKUniChar)c;
- (NSString *)bufferedString;
@end

@implementation PKToken (TDSignificantWhitespaceStateAdditions)

- (BOOL)isWhitespace {
    return self.tokenType == PKTokenTypeWhitespace;
}


- (NSString *)debugDescription {
    NSString *typeString = nil;
    if (self.isNumber) {
        typeString = @"Number";
    } else if (self.isQuotedString) {
        typeString = @"Quoted String";
    } else if (self.isSymbol) {
        typeString = @"Symbol";
    } else if (self.isWord) {
        typeString = @"Word";
    } else if (self.isWhitespace) {
        typeString = @"Whitespace";
    }
    return [NSString stringWithFormat:@"<%@ %C%@%C>", typeString, 0x00ab, self.value, 0x00bb];
}

@end

@implementation TDSignificantWhitespaceState

- (void)dealloc {
    [super dealloc];
}


- (PKToken *)nextTokenFromReader:(PKReader *)r startingWith:(PKUniChar)cin tokenizer:(PKTokenizer *)t {
    NSParameterAssert(r);
    [self resetWithReader:r];
    
    c = cin;
    while ([self isWhitespaceChar:c]) {
        [self append:c];
        c = [r read];
    }
    if (c != -1) {
        [r unread];
    }
    
    return [PKToken tokenWithTokenType:PKTokenTypeWhitespace stringValue:[self bufferedString] floatValue:0.0];
}

@end
