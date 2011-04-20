//
//  PKTokenizerState.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/20/06.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/PKTokenizerState.h>
#import <ParseKit/PKTokenizer.h>
#import <ParseKit/PKReader.h>
#import <ParseKit/PKTypes.h>

#define STATE_COUNT 256

@interface PKTokenizer ()
- (PKTokenizerState *)defaultTokenizerStateFor:(PKUniChar)c;
@end

@interface PKTokenizerState ()
- (void)resetWithReader:(PKReader *)r;
- (void)append:(PKUniChar)c;
- (void)appendString:(NSString *)s;
- (NSString *)bufferedString;
- (PKTokenizerState *)nextTokenizerStateFor:(PKUniChar)c tokenizer:(PKTokenizer *)t;

@property (nonatomic, retain) NSMutableString *stringbuf;
@property (nonatomic) NSUInteger offset;
@property (nonatomic, retain) NSMutableArray *fallbackStates;
@end

@implementation PKTokenizerState

- (void)dealloc {
    self.stringbuf = nil;
    self.fallbackState = nil;
    self.fallbackStates = nil;
    [super dealloc];
}


- (PKToken *)nextTokenFromReader:(PKReader *)r startingWith:(PKUniChar)cin tokenizer:(PKTokenizer *)t {
    NSAssert1(0, @"PKTokenizerState is an abstract classs. %s must be overriden", _cmd);
    return nil;
}


- (void)setFallbackState:(PKTokenizerState *)state from:(PKUniChar)start to:(PKUniChar)end {
    NSParameterAssert(start >= 0 && start < STATE_COUNT);
    NSParameterAssert(end >= 0 && end < STATE_COUNT);
    
    if (!fallbackStates) {
        self.fallbackStates = [NSMutableArray arrayWithCapacity:STATE_COUNT];

        NSInteger i = 0;
        for ( ; i < STATE_COUNT; i++) {
            [fallbackStates addObject:[NSNull null]];
        }
        
    }

    NSInteger i = start;
    for ( ; i <= end; i++) {
        [fallbackStates replaceObjectAtIndex:i withObject:state];
    }
}


- (void)resetWithReader:(PKReader *)r {
    self.stringbuf = [NSMutableString string];
    self.offset = r.offset - 1;
}


- (void)append:(PKUniChar)c {
    NSParameterAssert(c > -1);
    [stringbuf appendFormat:@"%C", c];
}


- (void)appendString:(NSString *)s {
    NSParameterAssert(s);
    [stringbuf appendString:s];
}


- (NSString *)bufferedString {
    return [[stringbuf copy] autorelease];
}


- (PKTokenizerState *)nextTokenizerStateFor:(PKUniChar)c tokenizer:(PKTokenizer *)t {
    NSParameterAssert(c < STATE_COUNT);
    
    if (fallbackStates) {
        id obj = [fallbackStates objectAtIndex:c];
        if ([NSNull null] != obj) {
            return obj;
        }
    }
    
    if (fallbackState) {
        return fallbackState;
    } else {
        return [t defaultTokenizerStateFor:c];
    }
}

@synthesize stringbuf;
@synthesize offset;
@synthesize fallbackState;
@synthesize fallbackStates;
@end
