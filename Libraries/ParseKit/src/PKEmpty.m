//
//  PKEmpty.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/13/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/PKEmpty.h>

@implementation PKEmpty

+ (id)empty {
    return [[[self alloc] init] autorelease];
}


- (NSSet *)allMatchesFor:(NSSet *)inAssemblies {
    NSParameterAssert(inAssemblies);
    //return [[[NSSet alloc] initWithSet:inAssemblies copyItems:YES] autorelease];
    return inAssemblies;
}

@end
