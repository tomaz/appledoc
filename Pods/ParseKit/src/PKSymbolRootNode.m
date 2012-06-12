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

#import <ParseKit/PKSymbolRootNode.h>
#import <ParseKit/PKReader.h>

@interface PKSymbolNode ()
@property (nonatomic, retain) NSMutableDictionary *children;
@end

@interface PKSymbolRootNode ()
- (void)addWithFirst:(PKUniChar)c rest:(NSString *)s parent:(PKSymbolNode *)p;
- (void)removeWithFirst:(PKUniChar)c rest:(NSString *)s parent:(PKSymbolNode *)p;
- (NSString *)nextWithFirst:(PKUniChar)c rest:(PKReader *)r parent:(PKSymbolNode *)p;
@end

@implementation PKSymbolRootNode

- (id)init {
    if (self = [super initWithParent:nil character:PKEOF]) {
        
    }
    return self;
}


- (void)add:(NSString *)s {
    NSParameterAssert(s);
    if ([s length] < 2) return;
    
    [self addWithFirst:[s characterAtIndex:0] rest:[s substringFromIndex:1] parent:self];
}


- (void)remove:(NSString *)s {
    NSParameterAssert(s);
    if ([s length] < 2) return;
    
    [self removeWithFirst:[s characterAtIndex:0] rest:[s substringFromIndex:1] parent:self];
}


- (void)addWithFirst:(PKUniChar)c rest:(NSString *)s parent:(PKSymbolNode *)p {
    NSParameterAssert(p);
    NSNumber *key = [NSNumber numberWithInteger:c];
    PKSymbolNode *child = [p->children objectForKey:key];
    if (!child) {
        child = [[PKSymbolNode alloc] initWithParent:p character:c];
        [p->children setObject:child forKey:key];
        [child release];
    }

    NSString *rest = nil;
    
    NSUInteger len = [s length];
    if (0 == len) {
        return;
    } else if (len > 1) {
        rest = [s substringFromIndex:1];
    }
    
    [self addWithFirst:[s characterAtIndex:0] rest:rest parent:child];
}


- (void)removeWithFirst:(PKUniChar)c rest:(NSString *)s parent:(PKSymbolNode *)p {
    NSParameterAssert(p);
    NSNumber *key = [NSNumber numberWithInteger:c];
    PKSymbolNode *child = [p->children objectForKey:key];
    if (child) {
        NSString *rest = nil;
        
        NSUInteger len = [s length];
        if (0 == len) {
            return;
        } else if (len > 1) {
            rest = [s substringFromIndex:1];
            [self removeWithFirst:[s characterAtIndex:0] rest:rest parent:child];
        }
        
        [p->children removeObjectForKey:key];
    }
}


- (NSString *)nextSymbol:(PKReader *)r startingWith:(PKUniChar)cin {
    NSParameterAssert(r);
    return [self nextWithFirst:cin rest:r parent:self];
}


- (NSString *)nextWithFirst:(PKUniChar)c rest:(PKReader *)r parent:(PKSymbolNode *)p {
    NSParameterAssert(p);
    NSString *result = [NSString stringWithFormat:@"%C", c];

    // this also works.
//    NSString *result = [[[NSString alloc] initWithCharacters:(const unichar *)&c length:1] autorelease];
    
    // none of these work.
    //NSString *result = [[[NSString alloc] initWithBytes:&c length:1 encoding:NSUTF8StringEncoding] autorelease];

//    NSLog(@"c: %d", c);
//    NSLog(@"string for c: %@", result);
//    NSString *chars = [[[NSString alloc] initWithCharacters:(const unichar *)&c length:1] autorelease];
//    NSString *utfs  = [[[NSString alloc] initWithUTF8String:(const char *)&c] autorelease];
//    NSString *utf8  = [[[NSString alloc] initWithBytes:&c length:1 encoding:NSUTF8StringEncoding] autorelease];
//    NSString *utf16 = [[[NSString alloc] initWithBytes:&c length:1 encoding:NSUTF16StringEncoding] autorelease];
//    NSString *ascii = [[[NSString alloc] initWithBytes:&c length:1 encoding:NSASCIIStringEncoding] autorelease];
//    NSString *iso   = [[[NSString alloc] initWithBytes:&c length:1 encoding:NSISOLatin1StringEncoding] autorelease];
//
//    NSLog(@"chars: '%@'", chars);
//    NSLog(@"utfs: '%@'", utfs);
//    NSLog(@"utf8: '%@'", utf8);
//    NSLog(@"utf16: '%@'", utf16);
//    NSLog(@"ascii: '%@'", ascii);
//    NSLog(@"iso: '%@'", iso);
    
    NSNumber *key = [NSNumber numberWithInteger:c];
    PKSymbolNode *child = [p->children objectForKey:key];
    
    if (!child) {
        if (p == self) {
            return result;
        } else {
            [r unread];
            return @"";
        }
    } 
    
    c = [r read];
    if (PKEOF == c) {
        return result;
    }
    
    return [result stringByAppendingString:[self nextWithFirst:c rest:r parent:child]];
}


- (NSString *)description {
    return @"<PKSymbolRootNode>";
}

@end
