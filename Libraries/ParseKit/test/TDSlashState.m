//
//  PKSlashState.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/20/06.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/TDSlashState.h>
#import <ParseKit/PKReader.h>
#import <ParseKit/PKTokenizer.h>
#import <ParseKit/PKToken.h>
#import <ParseKit/TDSlashSlashState.h>
#import <ParseKit/TDSlashStarState.h>

@interface TDSlashState ()
@property (nonatomic, retain) TDSlashSlashState *slashSlashState;
@property (nonatomic, retain) TDSlashStarState *slashStarState;
@end

@implementation TDSlashState

- (id)init {
    if (self = [super init]) {
        self.slashSlashState = [[[TDSlashSlashState alloc] init] autorelease];
        self.slashStarState  = [[[TDSlashStarState alloc] init] autorelease];
    }
    return self;
}


- (void)dealloc {
    self.slashSlashState = nil;
    self.slashStarState = nil;
    [super dealloc];
}


- (PKToken *)nextTokenFromReader:(PKReader *)r startingWith:(PKUniChar)cin tokenizer:(PKTokenizer *)t {
    NSParameterAssert(r);
    NSParameterAssert(t);
    
    NSInteger c = [r read];
    if ('/' == c) {
        return [slashSlashState nextTokenFromReader:r startingWith:c tokenizer:t];
    } else if ('*' == c) {
        return [slashStarState nextTokenFromReader:r startingWith:c tokenizer:t];
    } else {
        if (-1 != c) {
            [r unread];
        }
        return [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"/" floatValue:0.0];
    }
}

@synthesize slashSlashState;
@synthesize slashStarState;
@synthesize reportsCommentTokens;
@end
