//
//  PKAST.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/11/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "PKAST.h"

@interface PKAST ()
@property (nonatomic, retain) PKToken *token;
@property (nonatomic, retain) NSMutableArray *children;
@end

@implementation PKAST

+ (id)ASTWithToken:(PKToken *)tok {
    return [[[self alloc] initWithToken:tok] autorelease];
}


- (id)init {
    return [self initWithToken:nil];
}


- (id)initWithToken:(PKToken *)tok {
    if (self = [super init]) {
        self.token = tok;
    }
    return self;
}


- (void)dealloc {
    self.token = nil;
    self.children = nil;
    [super dealloc];
}


- (NSString *)description {
    return [token stringValue];
}


- (NSString *)treeDescription {
    if (![children count]) {
        return [self description];
    }
    
    NSMutableString *ms = [NSMutableString string];
    
    if (![self isNil]) {
        [ms appendFormat:@"(%@ ", [self description]];
    }

    NSInteger i = 0;
    for (PKAST *child in children) {
        if (i++) {
            [ms appendFormat:@" %@", child];
        } else {
            [ms appendFormat:@"%@", child];
        }
    }
    
    if (![self isNil]) {
        [ms appendString:@")"];
    }
    
    return [[ms copy] autorelease];
}


- (NSInteger)type {
    NSAssert2(0, @"%s is an abastract method. Must be overridden in %@", __PRETTY_FUNCTION__, NSStringFromClass([self class]));
    return -1;
}


- (void)addChild:(PKAST *)c {
    if (!children) {
        self.children = [NSMutableArray array];
    }
    [children addObject:c];
}


- (BOOL)isNil {
    return !token;
}

@synthesize token;
@synthesize children;
@end
