//
//  PKQuoteState.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/20/06.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/PKQuoteState.h>
#import <ParseKit/PKReader.h>
#import <ParseKit/PKToken.h>
#import <ParseKit/PKTypes.h>

@interface PKToken ()
@property (nonatomic, readwrite) NSUInteger offset;
@end

@interface PKTokenizerState ()
- (void)resetWithReader:(PKReader *)r;
- (void)append:(PKUniChar)c;
- (NSString *)bufferedString;
@end

@implementation PKQuoteState

- (void)dealloc {
    [super dealloc];
}


- (PKToken *)nextTokenFromReader:(PKReader *)r startingWith:(PKUniChar)cin tokenizer:(PKTokenizer *)t {
    NSParameterAssert(r);
    [self resetWithReader:r];
    
    [self append:cin];
    PKUniChar c;
    do {
        c = [r read];
        if (PKEOF == c) {
            c = cin;
            if (balancesEOFTerminatedQuotes) {
                [self append:c];
            }
        } else {
            [self append:c];
        }
        
    } while (c != cin);
    
    PKToken *tok = [PKToken tokenWithTokenType:PKTokenTypeQuotedString stringValue:[self bufferedString] floatValue:0.0];
    tok.offset = offset;
    return tok;
}

@synthesize balancesEOFTerminatedQuotes;
@end
