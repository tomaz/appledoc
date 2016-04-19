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

#import "PKIntersection.h"
#import <ParseKit/PKAssembly.h>

@interface NSMutableSet (PKIntersectionAdditions)
- (void)intersectSetTestingEquality:(NSSet *)s;
@end

@implementation NSMutableSet (PKIntersectionAdditions)

- (void)intersectSetTestingEquality:(NSSet *)s {
    for (id a1 in [[self copy] autorelease]) {
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
+ (PKCollectionParser *)collectionParserWithFirst:(PKParser *)p1 rest:(va_list)rest;
@end

@implementation PKIntersection

+ (PKIntersection *)intersection {
    return [self intersectionWithSubparsers:nil];
}


+ (PKIntersection *)intersectionWithSubparsers:(PKParser *)p1, ... {
    va_list vargs;
    va_start(vargs, p1);
    PKIntersection *inter = (PKIntersection *)[self collectionParserWithFirst:p1 rest:vargs];
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
