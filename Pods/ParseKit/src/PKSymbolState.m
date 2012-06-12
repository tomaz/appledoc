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

#import <ParseKit/PKSymbolState.h>
#import <ParseKit/PKToken.h>
#import <ParseKit/PKSymbolRootNode.h>
#import <ParseKit/PKReader.h>
#import <ParseKit/PKTokenizer.h>

@interface PKToken ()
@property (nonatomic, readwrite) NSUInteger offset;
@end

@interface PKTokenizerState ()
- (void)resetWithReader:(PKReader *)r;
- (PKTokenizerState *)nextTokenizerStateFor:(PKUniChar)c tokenizer:(PKTokenizer *)t;
@end

@interface PKSymbolState ()
- (PKToken *)symbolTokenWith:(PKUniChar)cin;
- (PKToken *)symbolTokenWithSymbol:(NSString *)s;

@property (nonatomic, retain) PKSymbolRootNode *rootNode;
@property (nonatomic, retain) NSMutableArray *addedSymbols;
@end

@implementation PKSymbolState

- (id)init {
    if (self = [super init]) {
        self.rootNode = [[[PKSymbolRootNode alloc] init] autorelease];
        self.addedSymbols = [NSMutableArray array];
    }
    return self;
}


- (void)dealloc {
    self.rootNode = nil;
    self.addedSymbols = nil;
    [super dealloc];
}


- (PKToken *)nextTokenFromReader:(PKReader *)r startingWith:(PKUniChar)cin tokenizer:(PKTokenizer *)t {
    NSParameterAssert(r);
    [self resetWithReader:r];
    
    NSString *symbol = [rootNode nextSymbol:r startingWith:cin];
    NSUInteger len = [symbol length];

    while (len > 1) {
        if ([addedSymbols containsObject:symbol]) {
            return [self symbolTokenWithSymbol:symbol];
        }

        symbol = [symbol substringToIndex:[symbol length] - 1];
        len = [symbol length];
        [r unread:1];
    }
    
    if (1 == len) {
        return [self symbolTokenWith:cin];
    } else {
        PKTokenizerState *state = [self nextTokenizerStateFor:cin tokenizer:t];
        if (!state || state == self) {
            return [self symbolTokenWith:cin];
        } else {
            return [state nextTokenFromReader:r startingWith:cin tokenizer:t];
        }
    }
}


- (void)add:(NSString *)s {
    NSParameterAssert(s);
    [rootNode add:s];
    [addedSymbols addObject:s];
}


- (void)remove:(NSString *)s {
    NSParameterAssert(s);
    [rootNode remove:s];
    [addedSymbols removeObject:s];
}


- (PKToken *)symbolTokenWith:(PKUniChar)cin {
    return [self symbolTokenWithSymbol:[NSString stringWithFormat:@"%C", cin]];
}


- (PKToken *)symbolTokenWithSymbol:(NSString *)s {
    PKToken *tok = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:s floatValue:0.0];
    tok.offset = offset;
    return tok;
}

@synthesize rootNode;
@synthesize addedSymbols;
@end
