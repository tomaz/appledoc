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

#import <ParseKit/PKTokenAssembly.h>
#import <ParseKit/PKTokenizer.h>
#import <ParseKit/PKToken.h>

@interface PKTokenAssembly ()
- (id)initWithString:(NSString *)s tokenzier:(PKTokenizer *)t tokenArray:(NSArray *)a;
- (void)tokenize;
- (NSString *)objectsFrom:(PKUniChar)start to:(PKUniChar)end separatedBy:(NSString *)delimiter;

@property (nonatomic, retain) PKTokenizer *tokenizer;
@property (nonatomic, copy) NSArray *tokens;
@end

@implementation PKTokenAssembly

+ (PKTokenAssembly *)assemblyWithTokenizer:(PKTokenizer *)t {
    return [[[self alloc] initWithTokenzier:t] autorelease];
}


+ (PKTokenAssembly *)assemblyWithTokenArray:(NSArray *)a {
    return [[[self alloc] initWithTokenArray:a] autorelease];
}


+ (PKTokenAssembly *)assemblyWithString:(NSString *)s {
    return (PKTokenAssembly *)[super assemblyWithString:s];
}


- (id)initWithTokenzier:(PKTokenizer *)t {
    return [self initWithString:t.string tokenzier:t tokenArray:nil];
}


- (id)initWithTokenArray:(NSArray *)a {
    return [self initWithString:[a componentsJoinedByString:@""] tokenzier:nil tokenArray:a];
}


- (id)initWithString:(NSString *)s {
    return [self initWithTokenzier:[[[PKTokenizer alloc] initWithString:s] autorelease]];
}


// designated initializer. this method is private and should not be called from other classes
- (id)initWithString:(NSString *)s tokenzier:(PKTokenizer *)t tokenArray:(NSArray *)a {
    self = [super initWithString:s];
    if (self) {
        if (t) {
            self.tokenizer = t;
        } else {
            self.tokens = a;
        }
    }
    return self;
}


- (void)dealloc {
    self.tokenizer = nil;
    self.tokens = nil;
    [super dealloc];
}


- (id)copyWithZone:(NSZone *)zone {
    PKTokenAssembly *a = (PKTokenAssembly *)[super copyWithZone:zone];
    a->tokenizer = nil; // optimization
    if (tokens) {
        a->tokens = [tokens copyWithZone:zone];
    } else {
        a->tokens = nil;
    }

    a->preservesWhitespaceTokens = preservesWhitespaceTokens;
    return a;
}


- (NSArray *)tokens {
    if (!tokens) {
        [self tokenize];
    }
    return tokens;
}


- (id)peek {
    PKToken *tok = nil;
    NSArray *toks = self.tokens;
    
    while (1) {
        if (index >= [toks count]) {
            tok = nil;
            break;
        }
        
        tok = [toks objectAtIndex:index];
        if (!preservesWhitespaceTokens) {
            break;
        }
        if (PKTokenTypeWhitespace == tok.tokenType) {
            [self push:tok];
            index++;
        } else {
            break;
        }
    }
    
    return tok;
}


- (id)next {
    id tok = [self peek];
    if (tok) {
        index++;
    }
    return tok;
}


- (BOOL)hasMore {
    return (index < [self.tokens count]);
}


- (NSUInteger)length {
    return [self.tokens count];
} 


- (NSUInteger)objectsConsumed {
    return index;
}


- (NSUInteger)objectsRemaining {
    return ([self.tokens count] - index);
}


- (NSString *)consumedObjectsJoinedByString:(NSString *)delimiter {
    NSParameterAssert(delimiter);
    return [self objectsFrom:0 to:self.objectsConsumed separatedBy:delimiter];
}


- (NSString *)remainingObjectsJoinedByString:(NSString *)delimiter {
    NSParameterAssert(delimiter);
    return [self objectsFrom:self.objectsConsumed to:[self length] separatedBy:delimiter];
}


#pragma mark -
#pragma mark Private

- (void)tokenize {
    if (!tokenizer) {
        self.tokenizer = [PKTokenizer tokenizerWithString:string];
    }
    
    NSMutableArray *a = [NSMutableArray array];
    
    PKToken *eof = [PKToken EOFToken];
    PKToken *tok = nil;
    while ((tok = [tokenizer nextToken]) != eof) {
        [a addObject:tok];
    }

    self.tokens = a;
}


- (NSString *)objectsFrom:(PKUniChar)start to:(PKUniChar)end separatedBy:(NSString *)delimiter {
    NSMutableString *s = [NSMutableString string];
    NSArray *toks = self.tokens;

    NSInteger i = start;
    for ( ; i < end; i++) {
        PKToken *tok = [toks objectAtIndex:i];
        [s appendString:tok.stringValue];
        if (end - 1 != i) {
            [s appendString:delimiter];
        }
    }
    
    return [[s copy] autorelease];
}

@synthesize tokenizer;
@synthesize tokens;
@synthesize preservesWhitespaceTokens;
@end
