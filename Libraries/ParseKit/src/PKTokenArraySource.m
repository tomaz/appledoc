//
//  PKTokenArraySource.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 12/11/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/PKTokenArraySource.h>
#import <ParseKit/PKToken.h>
#import <ParseKit/PKTokenizer.h>

@interface PKTokenArraySource ()
@property (nonatomic, retain) PKTokenizer *tokenizer;
@property (nonatomic, retain) NSString *delimiter;
@property (nonatomic, retain) PKToken *nextToken;
@end

@implementation PKTokenArraySource

- (id)init {
    return [self initWithTokenizer:nil delimiter:nil];
}


- (id)initWithTokenizer:(PKTokenizer *)t delimiter:(NSString *)s {
    NSParameterAssert(t);
    NSParameterAssert(s);
    if (self = [super init]) {
        self.tokenizer = t;
        self.delimiter = s;
    }
    return self;
}


- (void)dealloc {
    self.tokenizer = nil;
    self.delimiter = nil;
    self.nextToken = nil;
    [super dealloc];
}


- (BOOL)hasMore {
    if (!nextToken) {
        self.nextToken = [tokenizer nextToken];
    }

    return ([PKToken EOFToken] != nextToken);
}


- (NSArray *)nextTokenArray {
    if (![self hasMore]) {
        return nil;
    }
    
    NSMutableArray *res = [NSMutableArray arrayWithObject:nextToken];
    self.nextToken = nil;
    
    PKToken *eof = [PKToken EOFToken];
    PKToken *tok = nil;

    while ((tok = [tokenizer nextToken]) != eof) {
        if ([tok.stringValue isEqualToString:delimiter]) {
            break; // discard delimiter tok
        }
        [res addObject:tok];
    }
    
    //return [[res copy] autorelease];
    return res; // optimization
}

@synthesize tokenizer;
@synthesize delimiter;
@synthesize nextToken;
@end
