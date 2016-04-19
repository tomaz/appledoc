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

#import <ParseKit/PKParser.h>
#import <ParseKit/PKAssembly.h>
#import <ParseKit/PKTokenAssembly.h>
#import <ParseKit/PKTokenizer.h>

@interface PKAssembly ()
- (BOOL)hasMore;
@property (nonatomic, readonly) NSUInteger objectsConsumed;
@end

@interface PKParser ()
- (NSSet *)matchAndAssemble:(NSSet *)inAssemblies;
- (PKAssembly *)best:(NSSet *)inAssemblies;
@end

@interface PKParser (PKParserFactoryAdditionsFriend)
- (void)setTokenizer:(PKTokenizer *)t;
@end

@implementation PKParser

+ (PKParser *)parser {
    return [[[self alloc] init] autorelease];
}


- (void)dealloc {
#ifdef TARGET_OS_SNOW_LEOPARD
    self.assemblerBlock = nil;
    self.preassemblerBlock = nil;
#endif
    self.assembler = nil;
    self.assemblerSelector = nil;
    self.preassembler = nil;
    self.preassemblerSelector = nil;
    self.name = nil;
    self.tokenizer = nil;
    [super dealloc];
}


- (void)setAssembler:(id)a selector:(SEL)sel {
    self.assembler = a;
    self.assemblerSelector = sel;
}


- (void)setPreassembler:(id)a selector:(SEL)sel {
    self.preassembler = a;
    self.preassemblerSelector = sel;
}


- (PKParser *)parserNamed:(NSString *)s {
    if ([name isEqualToString:s]) {
        return self;
    }
    return nil;
}


- (NSSet *)allMatchesFor:(NSSet *)inAssemblies {
    NSAssert1(0, @"-[PKParser %s] must be overriden", _cmd);
    return nil;
}


- (PKAssembly *)bestMatchFor:(PKAssembly *)a {
    NSParameterAssert(a);
    NSSet *initialState = [NSSet setWithObject:a];
    NSSet *finalState = [self matchAndAssemble:initialState];
    return [self best:finalState];
}


- (PKAssembly *)completeMatchFor:(PKAssembly *)a {
    NSParameterAssert(a);
    PKAssembly *best = [self bestMatchFor:a];
    if (best && ![best hasMore]) {
        return best;
    }
    return nil;
}


- (NSSet *)matchAndAssemble:(NSSet *)inAssemblies {
    NSParameterAssert(inAssemblies);

#ifdef TARGET_OS_SNOW_LEOPARD
    if (preassemblerBlock) {
        for (PKAssembly *a in inAssemblies) {
            preassemblerBlock(a);
        }
    } else 
#endif
    if (preassembler) {
        NSAssert2([preassembler respondsToSelector:preassemblerSelector], @"provided preassembler %@ should respond to %s", preassembler, preassemblerSelector);
        for (PKAssembly *a in inAssemblies) {
            [preassembler performSelector:preassemblerSelector withObject:a];
        }
    }
    
    NSSet *outAssemblies = [self allMatchesFor:inAssemblies];

#ifdef TARGET_OS_SNOW_LEOPARD
    if (assemblerBlock) {
        for (PKAssembly *a in outAssemblies) {
            assemblerBlock(a);
        }
    } else 
#endif
    if (assembler) {
        NSAssert2([assembler respondsToSelector:assemblerSelector], @"provided assembler %@ should respond to %s", assembler, assemblerSelector);
        for (PKAssembly *a in outAssemblies) {
            [assembler performSelector:assemblerSelector withObject:a];
        }
    }
    return outAssemblies;
}


- (PKAssembly *)best:(NSSet *)inAssemblies {
    NSParameterAssert(inAssemblies);
    PKAssembly *best = nil;
    
    for (PKAssembly *a in inAssemblies) {
        if (![a hasMore]) {
            best = a;
            break;
        }
        if (!best || a.objectsConsumed > best.objectsConsumed) {
            best = a;
        }
    }
    
    return best;
}


- (NSString *)description {
    NSString *className = [NSStringFromClass([self class]) substringFromIndex:2];
    if ([name length]) {
        return [NSString stringWithFormat:@"%@ (%@)", className, name];
    } else {
        return [NSString stringWithFormat:@"%@", className];
    }
}

#ifdef TARGET_OS_SNOW_LEOPARD
@synthesize assemblerBlock;
@synthesize preassemblerBlock;
#endif
@synthesize assembler;
@synthesize assemblerSelector;
@synthesize preassembler;
@synthesize preassemblerSelector;
@synthesize name;
@end

@implementation PKParser (PKParserFactoryAdditions)

- (id)parse:(NSString *)s {
    PKTokenizer *t = self.tokenizer;
    if (!t) {
        t = [PKTokenizer tokenizer];
    }
    t.string = s;
    PKAssembly *a = [self completeMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    if (a.target) {
        return a.target;
    } else {
        return [a pop];
    }
}


- (PKTokenizer *)tokenizer {
    return [[tokenizer retain] autorelease];
}


- (void)setTokenizer:(PKTokenizer *)t {
    if (tokenizer != t) {
        [tokenizer autorelease];
        tokenizer = [t retain];
    }
}

@end
