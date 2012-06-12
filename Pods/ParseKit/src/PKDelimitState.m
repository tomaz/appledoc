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

#import <ParseKit/PKDelimitState.h>
#import <ParseKit/PKReader.h>
#import <ParseKit/PKTokenizer.h>
#import <ParseKit/PKToken.h>
#import <ParseKit/PKWhitespaceState.h>
#import <ParseKit/PKSymbolRootNode.h>
#import <ParseKit/PKTypes.h>

@interface PKToken ()
@property (nonatomic, readwrite) NSUInteger offset;
@end

@interface PKTokenizerState ()
- (void)resetWithReader:(PKReader *)r;
- (void)append:(PKUniChar)c;
- (void)appendString:(NSString *)s;
- (NSString *)bufferedString;
- (PKTokenizerState *)nextTokenizerStateFor:(PKUniChar)c tokenizer:(PKTokenizer *)t;
@end

@interface PKDelimitState ()
- (NSString *)endMarkerForStartMarker:(NSString *)startMarker;
- (NSCharacterSet *)allowedCharacterSetForStartMarker:(NSString *)startMarker;
@property (nonatomic, retain) PKSymbolRootNode *rootNode;
@property (nonatomic, retain) NSMutableArray *startMarkers;
@property (nonatomic, retain) NSMutableArray *endMarkers;
@property (nonatomic, retain) NSMutableArray *characterSets;
@end

@implementation PKDelimitState

- (id)init {
    if (self = [super init]) {
        self.rootNode = [[[PKSymbolRootNode alloc] init] autorelease];
        self.startMarkers = [NSMutableArray array];
        self.endMarkers = [NSMutableArray array];
        self.characterSets = [NSMutableArray array];
    }
    return self;
}


- (void)dealloc {
    self.rootNode = nil;
    self.startMarkers = nil;
    self.endMarkers = nil;
    self.characterSets = nil;
    [super dealloc];
}


- (void)addStartMarker:(NSString *)start endMarker:(NSString *)end allowedCharacterSet:(NSCharacterSet *)set {
    NSParameterAssert([start length]);
    [rootNode add:start];
    [startMarkers addObject:start];
    
    if ([end length]) {
        [rootNode add:end];
        [endMarkers addObject:end];
    } else {
        [endMarkers addObject:[NSNull null]];
    }

    if (set) {
        [characterSets addObject:set];
    } else {
        [characterSets addObject:[NSNull null]];
    }
}


- (void)removeStartMarker:(NSString *)start {
    NSParameterAssert([start length]);
    [rootNode remove:start];
    NSUInteger i = [startMarkers indexOfObject:start];
    if (NSNotFound != i) {
        [startMarkers removeObject:start];
        [characterSets removeObjectAtIndex:i];
        
        id endOrNull = [endMarkers objectAtIndex:i];
        if ([NSNull null] != endOrNull) {
            [rootNode remove:endOrNull];
        }
        [endMarkers removeObjectAtIndex:i]; // this should always be in range.
    }
}


- (NSString *)endMarkerForStartMarker:(NSString *)startMarker {
    NSParameterAssert([startMarkers containsObject:startMarker]);
    NSUInteger i = [startMarkers indexOfObject:startMarker];
    return [endMarkers objectAtIndex:i];
}


- (NSCharacterSet *)allowedCharacterSetForStartMarker:(NSString *)startMarker {
    NSParameterAssert([startMarkers containsObject:startMarker]);
    NSCharacterSet *characterSet = nil;
    NSUInteger i = [startMarkers indexOfObject:startMarker];
    id csOrNull = [characterSets objectAtIndex:i];
    if ([NSNull null] != csOrNull) {
        characterSet = csOrNull;
    }
    return characterSet;
}


- (PKToken *)nextTokenFromReader:(PKReader *)r startingWith:(PKUniChar)cin tokenizer:(PKTokenizer *)t {
    NSParameterAssert(r);
    NSParameterAssert(t);
    
    NSString *startMarker = [rootNode nextSymbol:r startingWith:cin];

    if (![startMarker length] || ![startMarkers containsObject:startMarker]) {
        [r unread:[startMarker length] - 1];
        return [[self nextTokenizerStateFor:cin tokenizer:t] nextTokenFromReader:r startingWith:cin tokenizer:t];
    }
    
    [self resetWithReader:r];
    [self appendString:startMarker];

    id endMarkerOrNull = [self endMarkerForStartMarker:startMarker];
    NSString *endMarker = nil;
    NSCharacterSet *characterSet = [self allowedCharacterSetForStartMarker:startMarker];
    
    PKUniChar c, e;
    if ([NSNull null] == endMarkerOrNull) {
        e = PKEOF;
    } else {
        endMarker = endMarkerOrNull;
        e = [endMarker characterAtIndex:0];
    }
    while (1) {
        c = [r read];
        if (PKEOF == c) {
            if (balancesEOFTerminatedStrings && endMarker) {
                [self appendString:endMarker];
            } else if (endMarker && !allowsUnbalancedStrings) {
                [r unread:[[self bufferedString] length] - 1];
                return [[self nextTokenizerStateFor:cin tokenizer:t] nextTokenFromReader:r startingWith:cin tokenizer:t];
            }
            break;
        }
        
        if (!endMarker && [t.whitespaceState isWhitespaceChar:c]) {
            // if only the start marker was matched, dont return delimited string token. instead, defer tokenization
            if ([startMarker isEqualToString:[self bufferedString]]) {
                [r unread:[startMarker length] - 1];
                return [[self nextTokenizerStateFor:cin tokenizer:t] nextTokenFromReader:r startingWith:cin tokenizer:t];
            }
            // else, return delimited string tok
            break;
        }
        
        if (e == c) {
            NSString *peek = [rootNode nextSymbol:r startingWith:e];
            if (endMarker && [endMarker isEqualToString:peek]) {
                [self appendString:endMarker];
                c = [r read];
                break;
            } else {
                [r unread:[peek length] - 1];
                if (e != [peek characterAtIndex:0]) {
                    [self append:c];
                    c = [r read];
                }
            }
        }

        // check if char is not in allowed character set (if given)
        if (characterSet && ![characterSet characterIsMember:c]) {
            if (allowsUnbalancedStrings) {
                break;
            } else {
                // if not, unwind and return a symbol tok for cin
                [r unread:[[self bufferedString] length]];
                return [[self nextTokenizerStateFor:cin tokenizer:t] nextTokenFromReader:r startingWith:cin tokenizer:t];
            }
        }
        
        [self append:c];
    }
    
    if (PKEOF != c) {
        [r unread];
    }
    
    PKToken *tok = [PKToken tokenWithTokenType:PKTokenTypeDelimitedString stringValue:[self bufferedString] floatValue:0.0];
    tok.offset = offset;
    return tok;
}

@synthesize rootNode;
@synthesize balancesEOFTerminatedStrings;
@synthesize allowsUnbalancedStrings;
@synthesize startMarkers;
@synthesize endMarkers;
@synthesize characterSets;
@end
