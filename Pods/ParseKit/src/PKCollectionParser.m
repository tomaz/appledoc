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

#import <ParseKit/PKCollectionParser.h>

@interface PKCollectionParser ()
+ (PKCollectionParser *)collectionParserWithFirst:(PKParser *)p1 rest:(va_list)rest;

@property (nonatomic, readwrite, retain) NSMutableArray *subparsers;
@end

@implementation PKCollectionParser

+ (PKCollectionParser *)collectionParserWithFirst:(PKParser *)p1 rest:(va_list)rest {
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
