//
//  PKSequence.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/13/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/PKSequence.h>
#import <ParseKit/PKAssembly.h>

@interface PKParser ()
- (NSSet *)matchAndAssemble:(NSSet *)inAssemblies;
@end

@interface PKCollectionParser ()
+ (id)collectionParserWithFirst:(PKParser *)p1 rest:(va_list)rest;
@end

@implementation PKSequence

+ (id)sequence {
    return [self sequenceWithSubparsers:nil];
}


+ (id)sequenceWithSubparsers:(PKParser *)p1, ... {
    va_list vargs;
    va_start(vargs, p1);
    PKSequence *seq = [self collectionParserWithFirst:p1 rest:vargs];
    va_end(vargs);
    return seq;
}


- (NSSet *)allMatchesFor:(NSSet *)inAssemblies {
    NSParameterAssert(inAssemblies);
    NSSet *outAssemblies = inAssemblies;
    
    for (PKParser *p in subparsers) {
        outAssemblies = [p matchAndAssemble:outAssemblies];
        if (![outAssemblies count]) {
            break;
        }
    }
    
    return outAssemblies;
}

@end
