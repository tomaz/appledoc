//
//  PKCollectionParser.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/13/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/PKCollectionParser.h>

@interface PKCollectionParser ()
+ (id)collectionParserWithFirst:(PKParser *)p1 rest:(va_list)rest;

@property (nonatomic, readwrite, retain) NSMutableArray *subparsers;
@end

@implementation PKCollectionParser

+ (id)collectionParserWithFirst:(PKParser *)p1 rest:(va_list)rest {
    PKCollectionParser *cp = [[[self alloc] init] autorelease];
    
    if (p1) {
        [cp add:p1];
        
        PKParser *p = nil;
        while (p = va_arg(rest, PKParser *)) {
            [cp add:p];
        }
    }
    
    return cp;
}


- (id)init {
    return [self initWithSubparsers:nil];
}


- (id)initWithSubparsers:(PKParser *)p1, ... {
    if (self = [super init]) {
        self.subparsers = [NSMutableArray array];

        if (p1) {
            [subparsers addObject:p1];

            va_list vargs;
            va_start(vargs, p1);

            PKParser *p = nil;
            while (p = va_arg(vargs, PKParser *)) {
                [subparsers addObject:p];
            }

            va_end(vargs);
        }
    }
    return self;
}


- (void)dealloc {
    self.subparsers = nil;
    [super dealloc];
}


- (void)add:(PKParser *)p {
    if (![p isKindOfClass:[PKParser class]]) {
        NSLog(@"p: %@", p);
    }
    NSParameterAssert([p isKindOfClass:[PKParser class]]);
    [subparsers addObject:p];
}


- (PKParser *)parserNamed:(NSString *)s {
    if ([name isEqualToString:s]) {
        return self;
    } else {
        // do bredth-first search
        for (PKParser *p in subparsers) {
            if ([p.name isEqualToString:s]) {
                return p;
            }
        }
        for (PKParser *p in subparsers) {
            PKParser *sub = [p parserNamed:s];
            if (sub) {
                return sub;
            }
        }
    }
    return nil;
}

@synthesize subparsers;
@end
