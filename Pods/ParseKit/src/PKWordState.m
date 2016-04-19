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

#import <ParseKit/PKWordState.h>
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

@interface PKWordState () 
- (BOOL)isWordChar:(PKUniChar)c;

@property (nonatomic, retain) NSMutableArray *wordChars;
@end

@implementation PKWordState

- (id)init {
    if (self = [super init]) {
        self.wordChars = [NSMutableArray arrayWithCapacity:256];
        NSInteger i = 0;
        for ( ; i < 256; i++) {
            [wordChars addObject:PKFALSE];
        }
        
        [self setWordChars:YES from: 'a' to: 'z'];
        [self setWordChars:YES from: 'A' to: 'Z'];
        [self setWordChars:YES from: '0' to: '9'];
        [self setWordChars:YES from: '-' to: '-'];
        [self setWordChars:YES from: '_' to: '_'];
        [self setWordChars:YES from:'\'' to:'\''];
        [self setWordChars:YES from:0xC0 to:0xFF];
    }
    return self;
}


- (void)dealloc {
    self.wordChars = nil;
    [super dealloc];
}


- (void)setWordChars:(BOOL)yn from:(PKUniChar)start to:(PKUniChar)end {
    NSUInteger len = [wordChars count];
    if (start > len || end > len || start < 0 || end < 0) {
        [NSException raise:@"PKWordStateNotSupportedException" format:@"PKWordState only supports setting word chars for chars in the latin1 set (under 256)"];
    }
    
    id obj = yn ? PKTRUE : PKFALSE;
    NSInteger i = start;
    for ( ; i <= end; i++) {
        [wordChars replaceObjectAtIndex:i withObject:obj];
    }
}


- (BOOL)isWordChar:(PKUniChar)c {    
    if (c > PKEOF && c < [wordChars count] - 1) {
        return (PKTRUE == [wordChars objectAtIndex:c]);
    }

    if (c >= 0x2000 && c <= 0x2BFF) { // various symbols
        return NO;
    } else if (c >= 0xFE30 && c <= 0xFE6F) { // general punctuation
        return NO;
    } else if (c >= 0xFE30 && c <= 0xFE6F) { // western musical symbols
        return NO;
    } else if (c >= 0xFF00 && c <= 0xFF65) { // symbols within Hiragana & Katakana
        return NO;            
    } else if (c >= 0xFFF0 && c <= 0xFFFF) { // specials
        return NO;        
    } else if (c < 0) {
        return NO;
    } else {
        return YES;
    }
}


- (PKToken *)nextTokenFromReader:(PKReader *)r startingWith:(PKUniChar)cin tokenizer:(PKTokenizer *)t {
    NSParameterAssert(r);
    [self resetWithReader:r];
    
    PKUniChar c = cin;
    do {
        [self append:c];
        c = [r read];
    } while ([self isWordChar:c]);
    
    if (PKEOF != c) {
        [r unread];
    }
    
    PKToken *tok = [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:[self bufferedString] floatValue:0.0];
    tok.offset = offset;
    return tok;
}


@synthesize wordChars;
@end
