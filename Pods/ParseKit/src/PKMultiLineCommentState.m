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

#import <ParseKit/PKMultiLineCommentState.h>
#import <ParseKit/PKCommentState.h>
#import <ParseKit/PKReader.h>
#import <ParseKit/PKTokenizer.h>
#import <ParseKit/PKToken.h>
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
@end

@interface PKCommentState ()
@property (nonatomic, retain) PKSymbolRootNode *rootNode;
@end

@interface PKMultiLineCommentState ()
- (void)addStartMarker:(NSString *)start endMarker:(NSString *)end;
- (void)removeStartMarker:(NSString *)start;
@property (nonatomic, retain) NSMutableArray *startMarkers;
@property (nonatomic, retain) NSMutableArray *endMarkers;
@property (nonatomic, copy) NSString *currentStartMarker;
@end

@implementation PKMultiLineCommentState

- (id)init {
    if (self = [super init]) {
        self.startMarkers = [NSMutableArray array];
        self.endMarkers = [NSMutableArray array];
    }
    return self;
}


- (void)dealloc {
    self.startMarkers = nil;
    self.endMarkers = nil;
    self.currentStartMarker = nil;
    [super dealloc];
}


- (void)addStartMarker:(NSString *)start endMarker:(NSString *)end {
    NSParameterAssert([start length]);
    NSParameterAssert([end length]);
    [startMarkers addObject:start];
    [endMarkers addObject:end];
}


- (void)removeStartMarker:(NSString *)start {
    NSParameterAssert([start length]);
    NSUInteger i = [startMarkers indexOfObject:start];
    if (NSNotFound != i) {
        [startMarkers removeObject:start];
        [endMarkers removeObjectAtIndex:i]; // this should always be in range.
    }
}


- (PKToken *)nextTokenFromReader:(PKReader *)r startingWith:(PKUniChar)cin tokenizer:(PKTokenizer *)t {
    NSParameterAssert(r);
    NSParameterAssert(t);
    
    BOOL balanceEOF = t.commentState.balancesEOFTerminatedComments;
    BOOL reportTokens = t.commentState.reportsCommentTokens;
    if (reportTokens) {
        [self resetWithReader:r];
        [self appendString:currentStartMarker];
    }
    
    NSUInteger i = [startMarkers indexOfObject:currentStartMarker];
    NSString *currentEndSymbol = [endMarkers objectAtIndex:i];
    PKUniChar e = [currentEndSymbol characterAtIndex:0];
    
    // get the definitions of all multi-char comment start and end symbols from the commentState
    PKSymbolRootNode *rootNode = t.commentState.rootNode;
        
    PKUniChar c;
    while (1) {
        c = [r read];
        if (PKEOF == c) {
            if (balanceEOF) {
                [self appendString:currentEndSymbol];
            }
            break;
        }
        
        if (e == c) {
            NSString *peek = [rootNode nextSymbol:r startingWith:e];
            if ([currentEndSymbol isEqualToString:peek]) {
                if (reportTokens) {
                    [self appendString:currentEndSymbol];
                }
                c = [r read];
                break;
            } else {
                [r unread:[peek length] - 1];
                if (e != [peek characterAtIndex:0]) {
                    if (reportTokens) {
                        [self append:c];
                    }
                    c = [r read];
                }
            }
        }
        if (reportTokens) {
            [self append:c];
        }
    }
    
    if (PKEOF != c) {
        [r unread];
    }
    
    self.currentStartMarker = nil;

    if (reportTokens) {
        PKToken *tok = [PKToken tokenWithTokenType:PKTokenTypeComment stringValue:[self bufferedString] floatValue:0.0];
        tok.offset = offset;
        return tok;
    } else {
        return [t nextToken];
    }
}

@synthesize startMarkers;
@synthesize endMarkers;
@synthesize currentStartMarker;
@end
