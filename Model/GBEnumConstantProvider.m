//
//  GBEnumConstantProvider.m
//  appledoc
//
//  Created by Rob van der Veer on 25/7/13.
//  Copyright (c) 2013 Gentle Bytes. All rights reserved.
//

#import "GBEnumConstantProvider.h"

@implementation GBEnumConstantProvider

- (id)initWithParentObject:(id)parent {
    NSParameterAssert(parent != nil);
    GBLogDebug(@"Initializing enumConstant provider for %@...", parent);
    self = [super init];
    if (self) {
        _parent = parent;
        _constants = [[NSMutableArray alloc] init];
        _useAlphabeticalOrder = YES;
    }
    return self;
}

-(void)registerConstant:(GBEnumConstantData *)constant {
    NSParameterAssert(constant != nil);
	if (!_constants) _constants = [[NSMutableArray alloc] init];
	[_constants addObject:constant];
}

@synthesize constants = _constants;
@end
