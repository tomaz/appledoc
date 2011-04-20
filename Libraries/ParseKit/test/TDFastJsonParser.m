//
//  PKFastJsonParser.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/14/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDFastJsonParser.h"
#import "ParseKit.h"
#import "NSString+ParseKitAdditions.h"

@interface TDFastJsonParser ()
- (void)didMatchDictionary;
- (void)didMatchArray;
- (NSArray *)objectsAbove:(id)fence;

@property (retain) PKTokenizer *tokenizer;
@property (retain) NSMutableArray *stack;
@property (retain) PKToken *curly;
@property (retain) PKToken *bracket;
@end

@implementation TDFastJsonParser

- (id)init {
    if (self = [super init]) {
        self.tokenizer = [PKTokenizer tokenizer];

        // configure tokenizer
        [tokenizer setTokenizerState:tokenizer.symbolState from: '/' to: '/']; // JSON doesn't have slash slash or slash star comments
        [tokenizer setTokenizerState:tokenizer.symbolState from: '\'' to: '\'']; // JSON does not have single quoted strings

        self.curly = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"{" floatValue:0.0];
        self.bracket = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"[" floatValue:0.0];
    }
    return self;
}


- (void)dealloc {
    self.tokenizer = nil;
    self.stack = nil;
    self.curly = nil;
    self.bracket = nil;
    [super dealloc];
}


- (id)parse:(NSString *)s {
    self.stack = [NSMutableArray array];
    
    tokenizer.string = s;
    PKToken *eof = [PKToken EOFToken];
    PKToken *tok = nil;
    
    while ((tok = [tokenizer nextToken]) != eof) {
        NSString *sval = tok.stringValue;
        
        if (tok.isSymbol) {
            if ([@"{" isEqualToString:sval]) {
                [stack addObject:tok];
            } else if ([@"}" isEqualToString:sval]) {
                [self didMatchDictionary];
            } else if ([@"[" isEqualToString:sval]) {
                [stack addObject:tok];
            } else if ([@"]" isEqualToString:sval]) {
                [self didMatchArray];
            }
        } else {
            id value = nil;
            if (tok.isQuotedString) {
                value = [sval stringByTrimmingQuotes];
            } else if (tok.isNumber) {
                value = [NSNumber numberWithFloat:tok.floatValue];
            } else { // if (tok.isWord) {
                if ([@"null" isEqualToString:sval]) {
                    value = [NSNull null];
                } else if ([@"true" isEqualToString:sval]) {
                    value = [NSNumber numberWithBool:YES];
                } else if ([@"false" isEqualToString:sval]) {
                    value = [NSNumber numberWithBool:NO];
                }
            }
            [stack addObject:value];
        }
    }
    
    return [stack lastObject];
}


- (void)didMatchDictionary {
    NSArray *a = [self objectsAbove:curly];
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:[a count]/2.];
    
    NSInteger i = [a count] - 1;
    for ( ; i >= 0; i--) {
        NSString *key = [a objectAtIndex:i--];
        id value = [a objectAtIndex:i];
        [result setObject:value forKey:key];
    }
    
    [stack addObject:result];
}


- (void)didMatchArray {
    NSArray *a = [self objectsAbove:bracket];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[a count]];
    for (id obj in [a reverseObjectEnumerator]) {
        [result addObject:obj];
    }
    [stack addObject:result];
}


- (NSArray *)objectsAbove:(id)fence {
    NSMutableArray *result = [NSMutableArray array];
    while (1) {
        id obj = [stack lastObject];
        [stack removeLastObject];
        if ([obj isEqual:fence]) {
            break;
        }
        [result addObject:obj];
    }
    return result;
}

@synthesize stack;
@synthesize tokenizer;
@synthesize curly;
@synthesize bracket;
@end
