//
//  PKTerminal.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/13/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/PKTerminal.h>
#import <ParseKit/PKAssembly.h>
#import <ParseKit/PKToken.h>

@interface PKAssembly ()
- (id)peek;
- (id)next;
- (BOOL)hasMore;
@property (nonatomic, readonly) NSUInteger objectsConsumed;
@end

@interface PKTerminal ()
- (PKAssembly *)matchOneAssembly:(PKAssembly *)inAssembly;
- (BOOL)qualifies:(id)obj;

@property (nonatomic, readwrite, copy) NSString *string;
@end

@implementation PKTerminal

- (id)init {
    return [self initWithString:nil];
}


- (id)initWithString:(NSString *)s {
    if (self = [super init]) {
        self.string = s;
    }
    return self;
}


- (void)dealloc {
    self.string = nil;
    [super dealloc];
}


- (NSSet *)allMatchesFor:(NSSet *)inAssemblies {
    NSParameterAssert(inAssemblies);
    NSMutableSet *outAssemblies = [NSMutableSet set];
    
    for (PKAssembly *a in inAssemblies) {
        PKAssembly *b = [self matchOneAssembly:a];
        if (b) {
            [outAssemblies addObject:b];
        }
    }
    
    return outAssemblies;
}


- (PKAssembly *)matchOneAssembly:(PKAssembly *)inAssembly {
    NSParameterAssert(inAssembly);
    if (![inAssembly hasMore]) {
        return nil;
    }
    
    PKAssembly *outAssembly = nil;
    
    if ([self qualifies:[inAssembly peek]]) {
        outAssembly = [[inAssembly copy] autorelease];
        id obj = [outAssembly next];
        if (!discardFlag) {
            [outAssembly push:obj];
        }
    }
    
    return outAssembly;
}


- (BOOL)qualifies:(id)obj {
    NSAssert1(0, @"-[PKTerminal %s] must be overriden", _cmd);
    return NO;
}


- (PKTerminal *)discard {
    discardFlag = YES;
    return self;
}

@synthesize string;
@end
