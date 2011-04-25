//
//  PKRepetition.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/13/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/PKRepetition.h>
#import <ParseKit/PKAssembly.h>

@interface PKParser ()
- (NSSet *)matchAndAssemble:(NSSet *)inAssemblies;
@end

@interface PKRepetition ()
@property (nonatomic, readwrite, retain) PKParser *subparser;
@end

@implementation PKRepetition

+ (id)repetitionWithSubparser:(PKParser *)p {
    return [[[self alloc] initWithSubparser:p] autorelease];
}


- (id)init {
    return [self initWithSubparser:nil];
}


- (id)initWithSubparser:(PKParser *)p {
    //NSParameterAssert(p);
    if (self = [super init]) {
        self.subparser = p;
    }
    return self;
}


- (void)dealloc {
    self.subparser = nil;
    [super dealloc];
}


- (PKParser *)parserNamed:(NSString *)s {
    if ([name isEqualToString:s]) {
        return self;
    } else {
        return [subparser parserNamed:s];
    }
}


- (NSSet *)allMatchesFor:(NSSet *)inAssemblies {
    NSParameterAssert(inAssemblies);
    //NSMutableSet *outAssemblies = [[[NSMutableSet alloc] initWithSet:inAssemblies copyItems:YES] autorelease];
    NSMutableSet *outAssemblies = [[inAssemblies mutableCopy] autorelease];
    
    NSSet *s = inAssemblies;
    while ([s count]) {
        s = [subparser matchAndAssemble:s];
        [outAssemblies unionSet:s];
    }
    
    return outAssemblies;
}

@synthesize subparser;
@end
