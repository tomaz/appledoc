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
