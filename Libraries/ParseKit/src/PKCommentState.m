//
//  PKCommentState.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 12/28/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/PKCommentState.h>
#import <ParseKit/PKTokenizer.h>
#import <ParseKit/PKToken.h>
#import <ParseKit/PKReader.h>
#import <ParseKit/PKSymbolRootNode.h>
#import <ParseKit/PKSingleLineCommentState.h>
#import <ParseKit/PKMultiLineCommentState.h>

@interface PKToken ()
@property (nonatomic, readwrite) NSUInteger offset;
@end

@interface PKTokenizerState ()
- (void)resetWithReader:(PKReader *)r;
- (PKTokenizerState *)nextTokenizerStateFor:(PKUniChar)c tokenizer:(PKTokenizer *)t;
@end

@interface PKCommentState ()
@property (nonatomic, retain) PKSymbolRootNode *rootNode;
@property (nonatomic, retain) PKSingleLineCommentState *singleLineState;
@property (nonatomic, retain) PKMultiLineCommentState *multiLineState;
@end

@interface PKSingleLineCommentState ()
- (void)addStartMarker:(NSString *)start;
- (void)removeStartMarker:(NSString *)start;
@property (nonatomic, retain) NSMutableArray *startMarkers;
@property (nonatomic, retain) NSString *currentStartMarker;
@end

@interface PKMultiLineCommentState ()
- (void)addStartMarker:(NSString *)start endMarker:(NSString *)end;
- (void)removeStartMarker:(NSString *)start;
@property (nonatomic, retain) NSMutableArray *startMarkers;
@property (nonatomic, retain) NSMutableArray *endMarkers;
@property (nonatomic, copy) NSString *currentStartMarker;
@end

@implementation PKCommentState

- (id)init {
    if (self = [super init]) {
        self.rootNode = [[[PKSymbolRootNode alloc] init] autorelease];
        self.singleLineState = [[[PKSingleLineCommentState alloc] init] autorelease];
        self.multiLineState = [[[PKMultiLineCommentState alloc] init] autorelease];
    }
    return self;
}


- (void)dealloc {
    self.rootNode = nil;
    self.singleLineState = nil;
    self.multiLineState = nil;
    [super dealloc];
}


- (void)addSingleLineStartMarker:(NSString *)start {
    NSParameterAssert([start length]);
    [rootNode add:start];
    [singleLineState addStartMarker:start];
}


- (void)removeSingleLineStartMarker:(NSString *)start {
    NSParameterAssert([start length]);
    [rootNode remove:start];
    [singleLineState removeStartMarker:start];
}


- (void)addMultiLineStartMarker:(NSString *)start endMarker:(NSString *)end {
    NSParameterAssert([start length]);
    NSParameterAssert([end length]);
    [rootNode add:start];
    [rootNode add:end];
    [multiLineState addStartMarker:start endMarker:end];
}


- (void)removeMultiLineStartMarker:(NSString *)start {
    NSParameterAssert([start length]);
    [rootNode remove:start];
    [multiLineState removeStartMarker:start];
}


- (PKToken *)nextTokenFromReader:(PKReader *)r startingWith:(PKUniChar)cin tokenizer:(PKTokenizer *)t {
    NSParameterAssert(r);
    NSParameterAssert(t);

    [self resetWithReader:r];

    NSString *symbol = [rootNode nextSymbol:r startingWith:cin];
    PKToken *tok = nil;
    
    while ([symbol length]) {
        if ([multiLineState.startMarkers containsObject:symbol]) {
            multiLineState.currentStartMarker = symbol;
            tok = [multiLineState nextTokenFromReader:r startingWith:cin tokenizer:t];
            if (tok.isComment) {
                tok.offset = offset;
            }
        } else if ([singleLineState.startMarkers containsObject:symbol]) {
            singleLineState.currentStartMarker = symbol;
            tok = [singleLineState nextTokenFromReader:r startingWith:cin tokenizer:t];
            if (tok.isComment) {
                tok.offset = offset;
            }
        }
        
        if (tok) {
            return tok;
        } else {
            if ([symbol length] > 1) {
                symbol = [symbol substringToIndex:[symbol length] -1];
            } else {
                break;
            }
            [r unread:1];
        }
    }

    return [[self nextTokenizerStateFor:cin tokenizer:t] nextTokenFromReader:r startingWith:cin tokenizer:t];
}

@synthesize rootNode;
@synthesize singleLineState;
@synthesize multiLineState;
@synthesize reportsCommentTokens;
@synthesize balancesEOFTerminatedComments;
@end
