//
//  PKSlashSlashState.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/20/06.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/TDSlashSlashState.h>
#import <ParseKit/TDSlashState.h>
#import <ParseKit/PKReader.h>
#import <ParseKit/PKTokenizer.h>
#import <ParseKit/PKToken.h>
#import <ParseKit/PKTypes.h>

@interface PKTokenizerState ()
- (void)resetWithReader:(PKReader *)r;
- (void)append:(PKUniChar)c;
- (NSString *)bufferedString;
@end

@implementation TDSlashSlashState

- (PKToken *)nextTokenFromReader:(PKReader *)r startingWith:(PKUniChar)cin tokenizer:(PKTokenizer *)t {
    NSParameterAssert(r);
    NSParameterAssert(t);
    
    BOOL reportTokens = t.slashState.reportsCommentTokens;
    if (reportTokens) {
        [self resetWithReader:r];
        [self append:'/'];
    }
    
    NSInteger c = cin;

    while ('\n' != c && '\r' != c && -1 != c) {
        if (reportTokens) {
            [self append:c];
        }
        c = [r read];
    }
    if (-1 != c) {
        [r unread];
    }
    
    if (reportTokens) {
        return [PKToken tokenWithTokenType:PKTokenTypeComment stringValue:[self bufferedString] floatValue:0.0];
    } else {
        return [t nextToken];
    }
}

@end
