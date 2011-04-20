//
//  PKSymbolRootNode.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/20/06.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

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
    self = [super initWithParent:nil character:PKEOF];
    if (self) {
        
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
    PKSymbolNode *child = [p.children objectForKey:key];
    if (!child) {
        child = [[PKSymbolNode alloc] initWithParent:p character:c];
        [p.children setObject:child forKey:key];
        [child release];
    }

    NSString *rest = nil;
    
    if (0 == [s length]) {
        return;
    } else if ([s length] > 1) {
        rest = [s substringFromIndex:1];
    }
    
    [self addWithFirst:[s characterAtIndex:0] rest:rest parent:child];
}


- (void)removeWithFirst:(PKUniChar)c rest:(NSString *)s parent:(PKSymbolNode *)p {
    NSParameterAssert(p);
    NSNumber *key = [NSNumber numberWithInteger:c];
    PKSymbolNode *child = [p.children objectForKey:key];
    if (child) {
        NSString *rest = nil;
        
        if (0 == [s length]) {
            return;
        } else if ([s length] > 1) {
            rest = [s substringFromIndex:1];
            [self removeWithFirst:[s characterAtIndex:0] rest:rest parent:child];
        }
        
        [p.children removeObjectForKey:key];
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
    PKSymbolNode *child = [p.children objectForKey:key];
    
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
