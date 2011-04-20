//
//  PKAlternation.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/13/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/PKAlternation.h>
#import <ParseKit/PKAssembly.h>

@interface PKParser ()
- (NSSet *)matchAndAssemble:(NSSet *)inAssemblies;
- (NSSet *)allMatchesFor:(NSSet *)inAssemblies;
@end

@interface PKCollectionParser ()
+ (id)collectionParserWithFirst:(PKParser *)p1 rest:(va_list)rest;
@end

@implementation PKAlternation

+ (id)alternation {
    return [self alternationWithSubparsers:nil];
}


+ (id)alternationWithSubparsers:(PKParser *)p1, ... {
    va_list vargs;
    va_start(vargs, p1);
    PKAlternation *alt = [self collectionParserWithFirst:p1 rest:vargs];
    va_end(vargs);
    return alt;
}


- (NSSet *)allMatchesFor:(NSSet *)inAssemblies {
    NSParameterAssert(inAssemblies);
    NSMutableSet *outAssemblies = [NSMutableSet set];
    
    for (PKParser *p in subparsers) {
        [outAssemblies unionSet:[p matchAndAssemble:inAssemblies]];
    }
    
    return outAssemblies;
}

@end
