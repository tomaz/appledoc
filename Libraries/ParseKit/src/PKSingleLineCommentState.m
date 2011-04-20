//
//  PKSingleLineCommentState.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 12/28/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/PKSingleLineCommentState.h>
#import <ParseKit/PKCommentState.h>
#import <ParseKit/PKReader.h>
#import <ParseKit/PKTokenizer.h>
#import <ParseKit/PKToken.h>
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

@interface PKSingleLineCommentState ()
- (void)addStartMarker:(NSString *)start;
- (void)removeStartMarker:(NSString *)start;
@property (nonatomic, retain) NSMutableArray *startMarkers;
@property (nonatomic, retain) NSString *currentStartMarker;
@end

@implementation PKSingleLineCommentState

- (id)init {
    if (self = [super init]) {
        self.startMarkers = [NSMutableArray array];
    }
    return self;
}


- (void)dealloc {
    self.startMarkers = nil;
    self.currentStartMarker = nil;
    [super dealloc];
}


- (void)addStartMarker:(NSString *)start {
    NSParameterAssert([start length]);
    [startMarkers addObject:start];
}


- (void)removeStartMarker:(NSString *)start {
    NSParameterAssert([start length]);
    [startMarkers removeObject:start];
}


- (PKToken *)nextTokenFromReader:(PKReader *)r startingWith:(PKUniChar)cin tokenizer:(PKTokenizer *)t {
    NSParameterAssert(r);
    NSParameterAssert(t);
    
    BOOL reportTokens = t.commentState.reportsCommentTokens;
    if (reportTokens) {
        [self resetWithReader:r];
        [self appendString:currentStartMarker];
    }
    
    PKUniChar c;
    while (1) {
        c = [r read];
        if ('\n' == c || '\r' == c || PKEOF == c) {
            break;
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
@synthesize currentStartMarker;
@end
