//
//  PKRuleNode.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/11/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "PKRuleNode.h"

@interface PKRuleNode ()
@property (nonatomic, copy, readwrite) NSString *name;
@end

@implementation PKRuleNode

+ (id)ruleNodeWithName:(NSString *)s {
    return [[[self alloc] initWithName:s] autorelease];
}


- (id)initWithName:(NSString *)s {
    if (self = [super init]) {
        self.name = s;
    }
    return self;
}


- (void)dealloc {
    self.name = nil;
    [super dealloc];
}


- (id)copyWithZone:(NSZone *)zone {
    PKRuleNode *n = [super copyWithZone:zone];
    n->name = [name copyWithZone:zone];
    return n;
}


- (NSString *)description {
    return [NSString stringWithFormat:@"<PKRuleNode '%@' %@>", name, children];
}

@synthesize name;
@end
