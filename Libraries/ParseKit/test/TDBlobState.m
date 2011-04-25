//
//  PKBlobState.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 6/7/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDBlobState.h"
#import <ParseKit/PKToken.h>
#import <ParseKit/PKReader.h>
#import "PKToken+Blob.h"

@interface PKToken ()
@property (nonatomic, readwrite) NSUInteger offset;
@end

@interface PKTokenizerState ()
- (void)resetWithReader:(PKReader *)r;
- (void)append:(PKUniChar)c;
- (NSString *)bufferedString;
@end

@implementation TDBlobState

- (PKToken *)nextTokenFromReader:(PKReader *)r startingWith:(PKUniChar)cin tokenizer:(PKTokenizer *)t {
    NSParameterAssert(r);
    [self resetWithReader:r];
    
    PKUniChar c = cin;
    do {
        [self append:c];
        c = [r read];
    } while (PKEOF != c && !isspace(c));
    
    if (PKEOF != c) {
        [r unread];
    }
    
    PKToken *tok = [PKToken tokenWithTokenType:PKTokenTypeBlob stringValue:[self bufferedString] floatValue:0.0];
    tok.offset = offset;
    return tok;
}

@end
