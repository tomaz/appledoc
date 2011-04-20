//
//  PKExclusion.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/2/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "PKExclusion.h"
#import <ParseKit/PKAssembly.h>

@interface NSMutableSet (PKExclusionAdditions)
- (void)exclusiveSetTestingEquality:(NSSet *)s;
@end

@implementation NSMutableSet (PKExclusionAdditions)

- (void)exclusiveSetTestingEquality:(NSSet *)s {
    for (id a1 in self) {
        BOOL found = NO;
        for (id a2 in s) {
            if ([a1 isEqual:a2 ]) {
                found = YES;
                break;
            }
        }
        if (found) {
            [self removeObject:a1];
        }
    }
    
    for (id a2 in s) {
        BOOL found = NO;
        for (id a1 in self) {
            if ([a2 isEqual:a1]) {
                found = YES;
                break;
            }
        }
        if (!found) {
            [self addObject:a2];
        }
    }
}

@end

@interface PKParser ()
- (NSSet *)matchAndAssemble:(NSSet *)inAssemblies;
- (NSSet *)allMatchesFor:(NSSet *)inAssemblies;
@end

@implementation PKExclusion

+ (id)exclusion {
    return [[[self alloc] init] autorelease];
}


- (NSSet *)allMatchesFor:(NSSet *)inAssemblies {
    NSParameterAssert(inAssemblies);
    NSMutableSet *outAssemblies = [NSMutableSet set];
    
    NSInteger i = 0;
    for (PKParser *p in subparsers) {
        if (0 == i++) {
            outAssemblies = [[[p matchAndAssemble:inAssemblies] mutableCopy] autorelease];
        } else {
            [outAssemblies exclusiveSetTestingEquality:[p allMatchesFor:inAssemblies]];
        }
    }
    
    return outAssemblies;
}

@end
