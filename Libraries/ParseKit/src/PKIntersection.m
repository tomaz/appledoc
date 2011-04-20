//
//  PKIntersection.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 6/27/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "PKIntersection.h"
#import <ParseKit/PKAssembly.h>

@interface NSMutableSet (PKIntersectionAdditions)
- (void)intersectSetTestingEquality:(NSSet *)s;
@end

@implementation NSMutableSet (PKIntersectionAdditions)

- (void)intersectSetTestingEquality:(NSSet *)s {
    for (id a1 in self) {
        BOOL found = NO;
        for (id a2 in s) {
            if ([a1 isEqual:a2]) {
                found = YES;
                break;
            }
        }
        if (!found) {
            [self removeObject:a1];
        }
    }
}

@end

@interface PKParser ()
- (NSSet *)matchAndAssemble:(NSSet *)inAssemblies;
- (NSSet *)allMatchesFor:(NSSet *)inAssemblies;
@end

@interface PKCollectionParser ()
+ (id)collectionParserWithFirst:(PKParser *)p1 rest:(va_list)rest;
@end

@implementation PKIntersection

+ (id)intersection {
    return [self intersectionWithSubparsers:nil];
}


+ (id)intersectionWithSubparsers:(PKParser *)p1, ... {
    va_list vargs;
    va_start(vargs, p1);
    PKIntersection *inter = [self collectionParserWithFirst:p1 rest:vargs];
    va_end(vargs);
    return inter;
}


- (NSSet *)allMatchesFor:(NSSet *)inAssemblies {
    NSParameterAssert(inAssemblies);
    NSMutableSet *outAssemblies = [NSMutableSet set];
    
    NSInteger i = 0;
    for (PKParser *p in subparsers) {
        if (0 == i++) {
            outAssemblies = [[[p matchAndAssemble:inAssemblies] mutableCopy] autorelease];
        } else {
            [outAssemblies intersectSetTestingEquality:[p allMatchesFor:inAssemblies]];
        }
    }
    
    return outAssemblies;
}

@end
