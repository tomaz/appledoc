//
//  PKWordOrReservedState.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/14/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/TDWordOrReservedState.h>

@interface TDWordOrReservedState ()
@property (nonatomic, retain) NSMutableSet *reservedWords;
@end

@implementation TDWordOrReservedState

- (id)init {
    if (self = [super init]) {
        self.reservedWords = [NSMutableSet set];
    }
    return self;
}


- (void)dealloc {
    self.reservedWords = nil;
    [super dealloc];
}


- (void)addReservedWord:(NSString *)s {
    [reservedWords addObject:s];
}


- (PKToken *)nextTokenFromReader:(PKReader *)r startingWith:(PKUniChar)cin tokenizer:(PKTokenizer *)t {
    NSParameterAssert(r);
    return nil;
}

@synthesize reservedWords;
@end
