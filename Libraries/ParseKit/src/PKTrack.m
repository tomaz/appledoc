//
//  PKTrack.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/13/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/PKTrack.h>
#import <ParseKit/PKAssembly.h>
#import <ParseKit/PKTrackException.h>

@interface PKAssembly ()
- (id)peek;
- (NSString *)consumedObjectsJoinedByString:(NSString *)delimiter;
@end

@interface PKParser ()
- (NSSet *)matchAndAssemble:(NSSet *)inAssemblies;
- (PKAssembly *)best:(NSSet *)inAssemblies;
@end

@interface PKTrack ()
- (void)throwTrackExceptionWithPreviousState:(NSSet *)inAssemblies parser:(PKParser *)p;
@end

@interface PKCollectionParser ()
+ (id)collectionParserWithFirst:(PKParser *)p1 rest:(va_list)rest;
@end

@implementation PKTrack

+ (id)track {
    return [self trackWithSubparsers:nil];
}


+ (id)trackWithSubparsers:(PKParser *)p1, ... {
    va_list vargs;
    va_start(vargs, p1);
    PKTrack *tr = [self collectionParserWithFirst:p1 rest:vargs];
    va_end(vargs);
    return tr;
}


- (NSSet *)allMatchesFor:(NSSet *)inAssemblies {
    NSParameterAssert(inAssemblies);
    BOOL inTrack = NO;
    NSSet *lastAssemblies = inAssemblies;
    NSSet *outAssemblies = inAssemblies;
    
    for (PKParser *p in subparsers) {
        outAssemblies = [p matchAndAssemble:outAssemblies];
        if (![outAssemblies count]) {
            if (inTrack) {
                [self throwTrackExceptionWithPreviousState:lastAssemblies parser:p];
            }
            break;
        }
        inTrack = YES;
        lastAssemblies = outAssemblies;
    }
    
    return outAssemblies;
}


- (void)throwTrackExceptionWithPreviousState:(NSSet *)inAssemblies parser:(PKParser *)p {
    PKAssembly *best = [self best:inAssemblies];

    NSString *after = [best consumedObjectsJoinedByString:@" "];
    if (![after length]) {
        after = @"-nothing-";
    }
    
    NSString *expected = [p description];

    id next = [best peek];
    NSString *found = next ? [next description] : @"-nothing-";
    
    NSString *reason = [NSString stringWithFormat:@"\n\nAfter : %@\nExpected : %@\nFound : %@\n\n", after, expected, found];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              after, @"after",
                              expected, @"expected",
                              found, @"found",
                              nil];
    [[PKTrackException exceptionWithName:PKTrackExceptionName reason:reason userInfo:userInfo] raise];
}

@end
