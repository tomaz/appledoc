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
- (PKTokenizerState *)nextTokenizerStateFor:(PKUniChar)c tokenizer:(PKTokenizer *)t;
@end

@implementation PKQuoteState

- (id)init {
    if (self = [super init]) {
        self.allowsEOFTerminatedQuotes = YES;
    }
    return self;
}


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
            if (allowsEOFTerminatedQuotes) {
                c = cin;
                if (balancesEOFTerminatedQuotes) {
                    [self append:c];
                }
            } else {
                [r unread:[[self bufferedString] length]];
                return [[self nextTokenizerStateFor:cin tokenizer:t] nextTokenFromReader:r startingWith:cin tokenizer:t];
            }
        } else if ((!usesCSVStyleEscaping && c == '\\') || (usesCSVStyleEscaping && c == cin)) {
            PKUniChar peek = [r read];
            if (peek == cin) {
                [self append:c];
                [self append:peek];
                c = PKEOF;	// Just to get past the while() condition
            } else {
                if (peek != PKEOF) {
                    [r unread:1];
                }
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

@synthesize allowsEOFTerminatedQuotes;
@synthesize balancesEOFTerminatedQuotes;
@synthesize usesCSVStyleEscaping;
@end
