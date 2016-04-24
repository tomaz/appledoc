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

#import <ParseKit/PKTokenizer.h>
#import <ParseKit/ParseKit.h>

#define STATE_COUNT 256

@interface PKToken ()
@property (nonatomic, readwrite) NSUInteger offset;
@end

@interface PKTokenizer ()
- (PKTokenizerState *)tokenizerStateFor:(PKUniChar)c;
- (PKTokenizerState *)defaultTokenizerStateFor:(PKUniChar)c;
@property (nonatomic, retain) PKReader *reader;
@property (nonatomic, retain) NSMutableArray *tokenizerStates;
@end

@implementation PKTokenizer

+ (PKTokenizer *)tokenizer {
    return [self tokenizerWithString:nil];
}


+ (PKTokenizer *)tokenizerWithString:(NSString *)s {
    return [[[self alloc] initWithString:s] autorelease];
}


- (id)init {
    return [self initWithString:nil];
}


- (id)initWithString:(NSString *)s {
    if (self = [super init]) {
        self.string = s;
        self.reader = [[[PKReader alloc] init] autorelease];
        
        self.numberState     = [[[PKNumberState alloc] init] autorelease];
        self.quoteState      = [[[PKQuoteState alloc] init] autorelease];
        self.commentState    = [[[PKCommentState alloc] init] autorelease];
        self.symbolState     = [[[PKSymbolState alloc] init] autorelease];
        self.whitespaceState = [[[PKWhitespaceState alloc] init] autorelease];
        self.wordState       = [[[PKWordState alloc] init] autorelease];
        self.delimitState    = [[[PKDelimitState alloc] init] autorelease];
        self.URLState        = [[[PKURLState alloc] init] autorelease];
        self.emailState      = [[[PKEmailState alloc] init] autorelease];
        self.twitterState    = [[[PKTwitterState alloc] init] autorelease];
        
        quoteState.fallbackState = symbolState;
        URLState.fallbackState = emailState;
        emailState.fallbackState = wordState;
        twitterState.fallbackState = symbolState;
        
        self.tokenizerStates = [NSMutableArray arrayWithCapacity:STATE_COUNT];
        
        NSInteger i = 0;
        for ( ; i < STATE_COUNT; i++) {
            [tokenizerStates addObject:[self defaultTokenizerStateFor:i]];
        }

        [symbolState add:@"<="];
        [symbolState add:@">="];
        [symbolState add:@"!="];
        [symbolState add:@"=="];
        
        [commentState addSingleLineStartMarker:@"//"];
        [commentState addMultiLineStartMarker:@"/*" endMarker:@"*/"];
        [self setTokenizerState:commentState from:'/' to:'/'];
    }
    return self;
}


- (void)dealloc {
    self.string = nil;
    self.reader = nil;
    self.tokenizerStates = nil;
    self.numberState = nil;
    self.quoteState = nil;
    self.commentState = nil;
    self.symbolState = nil;
    self.whitespaceState = nil;
    self.wordState = nil;
    self.delimitState = nil;
    self.URLState = nil;
    self.emailState = nil;
    self.twitterState = nil;
    [super dealloc];
}


- (PKToken *)nextToken {
    PKUniChar c = [reader read];
    
    PKToken *result = nil;
    
    if (PKEOF == c) {
        result = [PKToken EOFToken];
    } else {
        PKTokenizerState *state = [self tokenizerStateFor:c];
        if (state) {
            result = [state nextTokenFromReader:reader startingWith:c tokenizer:self];
        } else {
            result = [PKToken EOFToken];
        }
    }
    
    return result;
}


#ifdef TARGET_OS_SNOW_LEOPARD
- (void)enumerateTokensUsingBlock:(void (^)(PKToken *tok, BOOL *stop))block {
    PKToken *eof = [PKToken EOFToken];

    PKToken *tok = nil;
    BOOL stop = NO;
    
    while ((tok = [self nextToken]) != eof) {
        block(tok, &stop);
        if (stop) break;
    }
}
#endif


- (void)setTokenizerState:(PKTokenizerState *)state from:(PKUniChar)start to:(PKUniChar)end {
    NSParameterAssert(state);

    NSInteger i = start;
    for ( ; i <= end; i++) {
        [tokenizerStates replaceObjectAtIndex:i withObject:state];
    }
}


- (void)setReader:(PKReader *)r {
    if (reader != r) {
        [reader autorelease];
        reader = [r retain];
        reader.string = string;
    }
}


- (void)setString:(NSString *)s {
    if (string != s) {
        [string autorelease];
        string = [s retain];
    }
    reader.string = string;
}


#pragma mark -

- (PKTokenizerState *)tokenizerStateFor:(PKUniChar)c {
    if (c < 0 || c >= STATE_COUNT) {
        // customization above 255 is not supported, so fetch default.
        return [self defaultTokenizerStateFor:c];
    } else {
        // customization below 255 is supported, so be sure to get the (possibly) customized state from `tokenizerStates`
        return [tokenizerStates objectAtIndex:c];
    }
}


- (PKTokenizerState *)defaultTokenizerStateFor:(PKUniChar)c {
    if (c >= 0 && c <= ' ') {            // From:  0 to: 32    From:0x00 to:0x20
        return whitespaceState;
    } else if (c == 33) {
        return symbolState;
    } else if (c == '"') {               // From: 34 to: 34    From:0x22 to:0x22
        return quoteState;
    } else if (c >= 35 && c <= 38) {
        return symbolState;
    } else if (c == '\'') {              // From: 39 to: 39    From:0x27 to:0x27
        return quoteState;
    } else if (c >= 40 && c <= 42) {
        return symbolState;
    } else if (c == '+') {               // From: 43 to: 43    From:0x2B to:0x2B
        return symbolState;
    } else if (c == 44) {
        return symbolState;
    } else if (c == '-') {               // From: 45 to: 45    From:0x2D to:0x2D
        return numberState;
    } else if (c == '.') {               // From: 46 to: 46    From:0x2E to:0x2E
        return numberState;
    } else if (c == '/') {               // From: 47 to: 47    From:0x2F to:0x2F
        return symbolState;
    } else if (c >= '0' && c <= '9') {   // From: 48 to: 57    From:0x30 to:0x39
        return numberState;
    } else if (c >= 58 && c <= 63) {
        return symbolState;
    } else if (c == '@') {               // From: 64 to: 64    From:0x40 to:0x40
        return twitterState;
    } else if (c >= 'A' && c <= 'Z') {   // From: 65 to: 90    From:0x41 to:0x5A
        return URLState;
    } else if (c >= 91 && c <= 96) {
        return symbolState;
    } else if (c >= 'a' && c <= 'z') {   // From: 97 to:122    From:0x61 to:0x7A
        return URLState;
    } else if (c >= 123 && c <= 191) {
        return symbolState;
    } else if (c >= 0xC0 && c <= 0xFF) { // From:192 to:255    From:0xC0 to:0xFF
        return wordState;
    } else if (c >= 0x19E0 && c <= 0x19FF) { // khmer symbols
        return symbolState;
    } else if (c >= 0x2000 && c <= 0x2BFF) { // various symbols
        return symbolState;
    } else if (c >= 0x2E00 && c <= 0x2E7F) { // supplemental punctuation
        return symbolState;
    } else if (c >= 0x3000 && c <= 0x303F) { // cjk symbols & punctuation
        return symbolState;
    } else if (c >= 0x3200 && c <= 0x33FF) { // enclosed cjk letters and months, cjk compatibility
        return symbolState;
    } else if (c >= 0x4DC0 && c <= 0x4DFF) { // yijing hexagram symbols
        return symbolState;
    } else if (c >= 0xFE30 && c <= 0xFE6F) { // cjk compatibility forms, small form variants
        return symbolState;
    } else if (c >= 0xFF00 && c <= 0xFFFF) { // hiragana & katakana halfwitdh & fullwidth forms, Specials
        return symbolState;
    } else {
        return wordState;
    }
}

@synthesize numberState;
@synthesize quoteState;
@synthesize commentState;
@synthesize symbolState;
@synthesize whitespaceState;
@synthesize wordState;
@synthesize delimitState;
@synthesize URLState;
@synthesize emailState;
@synthesize twitterState;
@synthesize string;
@synthesize reader;
@synthesize tokenizerStates;
@end
